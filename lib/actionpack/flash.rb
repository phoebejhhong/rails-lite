require 'json'
require 'webrick'

class Flash
  def initialize(req, res)
    @res = res
    @now = false
    @cookie_value = {}
    req.cookies.each do |c|
      @cookie_value = JSON.parse(c.value) if c.name == "_rails_lite_app_flash"
    end
  end

  def [](key)
    @cookie_value[key]
  end

  def now
    @now = true
    @cookie_value
  end

  def []=(key, val)
    @cookie_value[key] = val
    store_session(@res) if @now
  end

  def reset_flash
    @cookie_value = {}
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app_flash", @cookie_value.to_json)
  end
end
