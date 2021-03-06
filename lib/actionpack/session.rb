require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @cookie_value = {}
    req.cookies.each do |c|
      @cookie_value = JSON.parse(c.value) if c.name == "_rails_lite_app"
    end
  end

  def [](key)
    @cookie_value[key.to_s]
  end

  def []=(key, val)
    @cookie_value[key.to_s] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app", @cookie_value.to_json)
  end
end
