require 'rack'
require_relative './lib/controller_base.rb'
require_relative './lib/router.rb'

class Airplane
  attr_reader :make, :model

  def self.all

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
  end

  # def inspect
  #
  # end
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
    @airplane = Airplane.all
    render :index
  end

  def new
    @airplane = Airplane.new
    render :new
  end
end

router = Router.new
