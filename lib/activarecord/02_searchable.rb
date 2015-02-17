require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

    attr_names = params.keys.map do |attr_name|
      "#{attr_name} = ?"
    end.join(' AND ')

    results = DBConnection.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{attr_names}
    SQL

    results.map { |result| new(result) }
  end
end

class SQLObject
    extend Searchable
end
