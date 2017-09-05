require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params, :already_built_response, :token, :session

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @session = Session.new(req)
    @@protect_from_forgery ||= false
  end

  def already_built_response?
    already_built_response
  end

  def redirect_to(url)
    raise 'Double Render Error' if already_built_response?

    res['Location'] = url
    res.status = 302
    session.store_session(res)
    @already_built_response = true
    flash.store_flash(res)
  end

  def render_content(content, content_type)
    raise 'Double Render Error' if already_built_response?

    res['Content-Type'] = content_type
    res.write(content)
    session.store_session(res)
    @already_built_response = true
    flash.store_flash(res)
  end

  def render(template_name)
    template_file = template_name.to_s + ".html.erb"
    path = "views/#{self.class.to_s.underscore}/#{template_file}"
    template = ERB.new(File.read(path)).result(binding)
    render_content(template, 'text/html')
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def session
    session
  end

  def invoke_action(name)
    if @@protect_from_forgery && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end

    self.send(name)
    render(name.to_s) unless already_built_response?
  end

  def form_authenticity_token
    @token ||= SecureRandom.urlsafe_base64(16)
    res.set_cookie("authenticity_token", value: token, path: "/")
    token
  end

  protected

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  private

  def check_authenticity_token
    auth_cookie = req.cookies["authenticity_token"]
    unless auth_cookie && auth_cookie == params["authenticity_token"]
      raise "Invalid authenticity token"
    end
  end
end
