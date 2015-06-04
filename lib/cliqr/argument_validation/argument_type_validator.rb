# encoding: utf-8
module Cliqr
  module ArgumentValidation
    # Validates type of a argument
    class ArgumentTypeValidator
      # Run the validation on a argument based on the option's configuration
      #
      # @return [Cliqr:ValidationErrors]
      def validate(argument, option, errors)
        errors.add("only values of type '#{option.type}' allowed for option '#{option.name}'") \
          unless type_of?(argument, option.type)
        errors
      end

      private

      # Check if a type of a argument matches a required type
      def type_of?(argument, required_type)
        case required_type
        when :numeric
          Integer(argument)
        when :boolean
          fail ArgumentError unless argument.class == TrueClass || argument.class == FalseClass
        end
        true
      rescue ArgumentError
        false
      end
    end
  end
end
