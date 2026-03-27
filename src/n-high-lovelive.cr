require "kemal"
require "http/client"

def get_forum()

end

get "/" do |env|
  send_file env, "./public/index.html"
end

Kemal.run
