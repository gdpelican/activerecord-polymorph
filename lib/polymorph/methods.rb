require "polymorph/relation"

module Polymorph
  module Methods
    def polymorph(method_name,
      through:,
      source_types:,
      fields: [:id],
      through_class: through.to_s.singularize.camelize.constantize,
      source_column: method_name.to_s.singularize,
      source_type:   "#{source_column}_type")

      define_method method_name, -> {

        query = send(through).select([
          source_types.map { |t| "#{t}.*" },
          source_types.product(fields).map { |a| "#{a[0]}.#{a[1]} AS #{a[0].to_s.singularize}_#{a[1]}" },
          "#{through}.#{source_column}_type",
          "'is_polymorph' as polymorph_query"
        ].flatten.join(', '))

        source_types.each do |type|
          query = query.joins(%{
            LEFT OUTER JOIN #{type}
            ON #{type}.id = #{through}.#{source_column}_id
            AND '#{type.to_s.singularize.camelize}' = #{through}.#{source_type}
          })
        end

        Polymorph::Relation.new(query, fields: fields, source_types: source_types)
      }

      through_class.define_singleton_method :instantiate, ->(attrs, column_types) {
        super(attrs, column_types).tap do |record|
          break unless attrs['polymorph_query'].present?
          transfer_fields = fields.map { |field| [field, attrs["#{attrs[source_type].downcase}_#{field}"]] }.to_h
          record.assign_attributes(transfer_fields)
        end
      }

      through_class.define_singleton_method :discriminate_class_for_record, ->(attributes) {
        return super(attributes) unless attributes['polymorph_query'].present?
        attributes["#{source_column}_type"].camelize.constantize
      }
    end
  end
end
