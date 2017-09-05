require 'json'

class Flash
  attr_reader :now, :flash

  def initialize(req)
    cookie = req.cookies['_runway_app_flash']

    @now = cookie ? JSON.parse(cookie) : {}
    @flash = {}
  end

  def [](key)
    now[key.to_s] || flash[key.to_s]
  end

  def []=(key, value)
    flash[key.to_s] = value
  end

  def store_flash(res)
    res.set_cookie('_runway_app_flash', value: flash.to_json)
  end
end
