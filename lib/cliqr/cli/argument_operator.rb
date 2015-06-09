# encoding: utf-8

module Cliqr
  module CLI
    # Operates on the value of a argument after it has been validated
    #
    # @api private
    class ArgumentOperator
      # Default pass through argument operator
      DEFAULT_ARGUMENT_OPERATOR = ArgumentOperator.new

      # Get a new ArgumentOperator for a argument type
      #
      # @return [Cliqr::CLI::ArgumentOperator]
      def self.for_type(type)
        case type
        when CLI::NUMERIC_ARGUMENT_TYPE
          NumericArgumentOperator.new
        else
          DEFAULT_ARGUMENT_OPERATOR
        end
      end

      # Return the same value back without any change
      #
      # @return [String]
      def operate(value)
        value
      end
    end

    # Handle numerical arguments
    #
    # @api private
    class NumericArgumentOperator < ArgumentOperator
      # Convert the argument to a integer value
      #
      # @return [Integer]
      def operate(value)
        value.to_i
      end
    end
  end
end
