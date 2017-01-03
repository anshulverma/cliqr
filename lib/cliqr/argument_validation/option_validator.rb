# frozen_string_literal: true
module Cliqr
  module ArgumentValidation
    # Runs all validators configured for an option
    class OptionValidator
      # Create a new option validator
      def initialize
        @validators = Set.new []
      end

      # Add a validator for this option
      #
      # @return [Set] All validators configured so far
      def add(validator)
        @validators.add(validator)
      end

      # Run all the validators for a option
      #
      # @return [Cliqr::ValidationErrors]
      def validate(values, option, errors)
        @validators.each do |validator|
          values.each { |value| validator.validate(value, option, errors) }
        end
        errors
      end
    end
  end
end
