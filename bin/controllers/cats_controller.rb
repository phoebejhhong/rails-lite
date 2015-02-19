require_relative '../../lib/actionpack/controller_base'
require_relative '../models/cat'

class CatsController < ControllerBase
  def create
    @cat = Cat.new(params["cat"])
    if @cat.save
      flash[:notice] = ["#{@cat.name} is saved!"]
      redirect_to("/cats")
    else
      flash.now[:notice] = ["Fill all the fields!"]
      render :new
    end
  end

  def index
    @cats = Cat.all
    render :index
  end

  def show
    @cat = Cat.all.select do |cat|
      cat.id == Integer(params[:cat_id])
    end.first

    render :show
  end

  def new
    @cat = Cat.new
    render :new
  end

  def destroy
    @cat = Cat.all.select do |cat|
      cat.id == Integer(params[:cat_id])
    end.first
    redirect_to("/cats")
  end
end
