class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller = controller_class
    @action = action_name
  end

  def matches?(req)
    @pattern.match?(req.path) && req.request_method == @http_method.to_s.upcase
  end

  def run(req, res)
    path = req.path
    regex = Regexp.new(@pattern)
    match_data = regex.match(path)
    route_params = {}
    match_data.names.each { |k| route_params[k] = match_data[k] }
    @controller.new(req, res, route_params).invoke_action(@action)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    routes.select do |route|
      route.http_method.to_s.upcase == req.request_method && route.pattern.match?(req.path)
    end.first
  end

  def run(req, res)
    if match(req)
      match(req).run(req, res)
    else
      res.status = 404
    end
  end
end
