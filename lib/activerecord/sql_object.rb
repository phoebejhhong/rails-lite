require_relative 'searchable'
require_relative 'associatable'
require_relative '../db_connection'
require 'active_support/inflector'

class SQLObject
  extend Associatable
  extend Searchable

  def self.columns
    DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{table_name}
    SQL
  end

  def self.finalize!
    define_method(:attributes) do
      @attributes ||= {}
    end

    columns.each do |column|
      table_name = @table_name
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |new_value|
        attributes[column] = new_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    auto_tableized = self.to_s.tableize
    if auto_tableized[-1] == "s"
      @table_name = auto_tableized
    else
      @table_name = self.to_s.downcase + "s"
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << self.new(result)
    end

    objects
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    result.empty? ? nil : self.new(result.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      columns = self.class.columns

      if columns.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes

  end

  def attribute_values
    self.class.columns.map { |col| attributes[col] }
  end

  def insert
    col_names = self.class.columns.join(',')
    question_marks = ["?"] * col_names.split(',').size
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks.join(', ')})
    SQL
    attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.map do |attr_name|
      "#{attr_name} = ?"
    end.join(',')

    DBConnection.execute(<<-SQL, attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
