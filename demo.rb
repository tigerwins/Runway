require 'rack'
require_relative './lib/controller_base.rb'
require_relative './lib/router.rb'
require_relative './lib/static.rb'

class Airplane
  attr_reader :make, :model

  def self.all
    @airplanes ||= []
  end

  def initialize(params = {})
    params ||= {}
    @make, @model = params["make"], params["model"]
  end

  def errors
    @errors ||= []
  end

  def valid?
    unless @make.present?
      errors << "Make must be present"
      return false
    end

    unless @model.present?
      errors << "Model must be present"
      return false
    end

    true
  end

  def save
    return false unless valid?
    Airplane.all << self
    true
  end

  def inspect
    { make: make, model: model }.inspect
  end
end

class AirplanesController < ControllerBase
  protect_from_forgery

  def create
    @airplane = Airplane.new(params["airplane"])
    if @airplane.save
      flash[:notice] = "Airplane was added successfully!"
      redirect_to "/airplanes"
    else
      flash.now[:errors] = @airplane.errors
      render :new
    end
  end

  def index
    @airplanes = Airplane.all
    render :index
  end

  def new
    @airplane = Airplane.new
    render :new
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/$"), AirplanesController, :index
  get Regexp.new("^/airplanes$"), AirplanesController, :index
  get Regexp.new("^/airplanes/new$"), AirplanesController, :new
  get Regexp.new("^/airplanes/(?<id>\\d+)$"), AirplanesController, :show
  post Regexp.new("^/airplanes$"), AirplanesController, :create
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use Static
  run app
end.to_app

Rack::Server.start(
  app: app,
  Port: 3000
)
