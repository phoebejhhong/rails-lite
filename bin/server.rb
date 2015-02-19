require 'webrick'
require_relative '../lib/actionpack/controller_base'
require_relative '../lib/actionpack/router'
require_relative './controllers/cats_controller'

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
