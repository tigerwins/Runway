require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
    rescue Exception => e
      render_exception(e)
  end

  private

  def render_exception(e)
    path = File.dirname(__FILE__)
    template_path = [path, "templates", "rescue.html.erb"].join("/")
    error_template = File.read(template_path)
    error_body = ERB.new(error_template).result(binding)

    ["500", { "Content-type" => "text/html" }, error_body]
  end
end
