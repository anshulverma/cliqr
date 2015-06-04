# encoding: utf-8
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
      def validate(argument, option, errors)
        @validators.each { |validator| validator.validate(argument, option, errors) }
        errors
      end
    end
  end
end
