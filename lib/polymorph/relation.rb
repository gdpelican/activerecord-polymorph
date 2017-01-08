module Polymorph
  class Relation < SimpleDelegator

    def initialize(query, source_types:, fields:)
      @source_types, @fields = source_types, fields
      super(query)
    end

    def count
      self.to_a.length
    end

    def pluck(field)
      self.to_a.map(&field)
    end

    def where(hash = {})
      fields = hash.slice(*@fields)
      fields.map do |field|
        %{(
          #{@source_types.map { |type| "#{type}.#{field[0]} = :#{field[0]}" }.join(" OR ")}
        )}
      end.join(" AND ")
      rebuild(super(clause, fields))
    end

    private

    def rebuild(query)
      self.class.new(query, source_types: @source_types, fields: @fields)
    end
  end
end
