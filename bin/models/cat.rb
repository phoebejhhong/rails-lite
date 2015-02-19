require_relative '../../lib/activerecord/sql_object'

class Cat < SQLObject
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
