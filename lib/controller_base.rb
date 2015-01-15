require 'active_support/inflector'
require 'erb'
require_relative './url_helper'
require_relative './params'
require_relative './session'
require_relative './flash'

class ControllerBase
  include UrlHelper

  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    f = File.open("views/#{controller_name}/#{template_name}.html.erb", "r")
    template = ERB.new(f.read).result(binding)
    f.close
    render_content(template, "text/html")
  end

  def already_built_response?
    @already_built_response ||= false
  end

  def redirect_to(url)
    raise if @already_built_response
    res.status = 302
    res.header["location"] = url
    @already_built_response = true
    session.store_session(res)
    flash.reset_flash if flash["notice"]
    flash.store_session(res)
  end

  def render_content(content, type)
    raise if @already_built_response
    res.content_type = type
    res.body = content
    @already_built_response = true
    session.store_session(res)
    flash.reset_flash if flash["notice"]
    flash.store_session(res)
  end

  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req, res)
  end

  def invoke_action(name)
    self.send(name)
    self.send(:render) unless already_built_response?
  end
end
