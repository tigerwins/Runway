require 'json'

class Session
  attr_reader :cookie

  def initialize(req)
    if req.cookies['_runway_app']
      @cookie = JSON.parse(req.cookies['_runway_app'])
    else
      @cookie = {}
    end
  end

  def [](key)
    cookie[key]
  end

  def []=(key, val)
    cookie[key] = val
  end

  def store_session(res)
    res.set_cookie('_runway_app', { path: "/", value: cookie.to_json })
  end
end
