require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]

    define_method(name) do
      source_options =
        through_options.model_class.assoc_options[source_name]
      # above is something like house's_assoc_options[:owner]

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{source_options.table_name}.*
          -- 'houses'.*
        FROM
          #{through_options.table_name}
          -- 'humans'
        JOIN
          #{source_options.table_name}
          -- 'houses'
          ON #{source_options.table_name}.#{source_options.primary_key} = #{through_options.table_name}.#{source_options.foreign_key}
            -- id = humans.house_id
        WHERE
          #{through_options.table_name}.#{source_options.primary_key}
            = #{self.send(through_options.foreign_key)}
        SQL

        results.map { |result| source_options.model_class.new(result) }.first
    end
  end
end
