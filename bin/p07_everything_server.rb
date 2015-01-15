require 'webrick'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class Cat
  attr_reader :name, :owner, :id

  def self.all
    @cat ||= []
  end

  def initialize(params = {})
    params ||= {}
    @name, @owner = params["name"], params["owner"]
  end

  def save
    return false if @name.empty? || @owner.empty?
    @id = rand(100)
    Cat.all << self
    true
  end

  def inspect
    { id: id, name: name, owner: owner }.inspect
  end
end


class StatusesController < ControllerBase
  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params[:cat_id])
    end

    render_content(statuses.to_s, "text/text")
  end
end

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

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)$"), CatsController, :show
  delete Regexp.new("^/cats/(?<cat_id>\\d+)$"), CatsController, :destroy
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end



trap('INT') { server.shutdown }
server.start
