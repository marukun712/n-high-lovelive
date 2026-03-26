require "kemal"

get "/" do |env|
  send_file env, "./public/index.html"
end

Kemal.run
