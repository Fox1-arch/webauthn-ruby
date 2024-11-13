# frozen_string_literal: true

module WebAuthn
  module JSONSerializer
    # Argument wildcard for Ruby on Rails controller automatic object JSON serialization
    def as_json(*)
      to_hash_with_camelized_keys
    end

    private

    def to_hash_with_camelized_keys
      attributes.each_with_object({}) do |attribute_name, hash|
        value = send(attribute_name)

        if value.respond_to?(:as_json)
          hash[camelize(attribute_name)] = value.as_json
        elsif value
          hash[camelize(attribute_name)] = deep_camelize_keys(value)
        end
      end
    end

    def deep_camelize_keys(object)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[camelize(key)] = deep_camelize_keys(value)
        end
      when Array
        object.map { |element| deep_camelize_keys(element) }
      else
        object
      end
    end

    def camelize(term)
      first_term, *rest = term.to_s.split('_')

      [first_term, *rest.map(&:capitalize)].join.to_sym
    end
  end
end