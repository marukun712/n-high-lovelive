require "kemal"
require "http/client"
require "markd"
require "sanitize"

sanitizer = Sanitize::Policy::HTMLSanitizer.common
sanitizer.valid_classes << /language-.+/

TOKEN    = ENV["DISCORD_TOKEN"]
GUILD_ID = ENV["GUILD_ID"]
FORUM_ID = ENV["FORUM_ID"]

def list_posts
  response = HTTP::Client.get(
    "https://discord.com/api/v10/guilds/#{GUILD_ID}/threads/active",
    headers: HTTP::Headers{"Authorization" => "Bot #{TOKEN}"}
  )

  raise "Discord API error: #{response.status_code}" unless response.success?

  data = JSON.parse(response.body)
  threads = data["threads"].as_a
  forum_threads = threads.select { |t| t["parent_id"].as_s? == FORUM_ID }
  forum_threads.map { |t| {id: t["id"].as_s? || "", name: t["name"].as_s? || ""} }
rescue ex : Exception
  Log.error { "list_posts failed: #{ex.message}" }
  [] of {id: String, name: String}
end

def get_post(id : String) : {title: String, content: String}
  ch_response = HTTP::Client.get(
    "https://discord.com/api/v10/channels/#{id}",
    headers: HTTP::Headers{"Authorization" => "Bot #{TOKEN}"}
  )
  raise "Discord API error: #{ch_response.status_code}" unless ch_response.success?
  ch_data = JSON.parse(ch_response.body)
  raise "Invalid Channel" if ch_data["parent_id"].as_s? != FORUM_ID

  title = ch_data["name"].as_s? || ""

  msg_response = HTTP::Client.get(
    "https://discord.com/api/v10/channels/#{id}/messages/#{id}",
    headers: HTTP::Headers{"Authorization" => "Bot #{TOKEN}"}
  )
  raise "Discord API error: #{msg_response.status_code}" unless msg_response.success?
  content = JSON.parse(msg_response.body)["content"].as_s? || ""

  {title: title, content: content}
end

get "/" do |env|
  send_file env, "./public/index.html"
end

get "/blog" do |env|
  send_file env, "./public/blog.html"
end

get "/post" do |env|
  send_file env, "./public/post.html"
end

get "/posts" do |env|
  begin
    posts = list_posts()
    html = String.build do |str|
      posts.each do |post|
        str << <<-HTML
          <article>
            <header>
              <a href="/post?id=#{HTML.escape(post[:id].to_s)}">
                <h1>#{HTML.escape(post[:name].to_s)}</h1>
              </a>
            </header>
          </article>
        HTML
      end
    end
    html
  rescue ex : Exception
    env.response.status_code = 500
    Log.error { "Failed to load posts: #{ex.message}" }
    "<p>投稿一覧の読み込みに失敗しました</p>"
  end
end

get "/content/:id" do |env|
  id = env.params.url["id"]

  unless id.to_u64?
    env.response.status_code = 400
    next "Invalid ID"
  end

  begin
    post = get_post(id)
    html = Markd.to_html(post["content"])
    parsed = sanitizer.process(html)
    "<div><h2 class=\"section-title\">#{HTML.escape(post["title"])}</h2>#{parsed}</div>"
  rescue ex : Exception
    env.response.status_code = 500
    Log.error { "Failed to load content #{id}: #{ex.message}" }
    "<p>コンテンツの読み込みに失敗しました</p>"
  end
end

Kemal.run
