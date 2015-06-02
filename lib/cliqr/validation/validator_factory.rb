# encoding: utf-8

module Cliqr
  module Validation
    # A factory class to retrieve a attribute validator based on the configuration type
    #
    # @api private
    module ValidatorFactory
      # Get a new validator based on the type and config param
      #
      # @return [Cliqr::Validation::ValidatorFactory::Validator]
      def self.get(validator_type, config)
        case (validator_type)
        when :presence
          PresenceValidator.new if config
        when :format
          FormatValidator.new(config)
        when :extend
          TypeHierarchyValidator.new(config)
        else
          Validator.new(validator_type)
        end
      end

      # Does not validates anything, used by default if a unknown validator type is used
      class Validator
        # Initialize a Validator
        def initialize(type)
          @type = type
        end

        # Fails if invoked
        #
        # @return [Object]
        def validate(_name, _value, _errors)
          fail Cliqr::Error::UnknownValidatorType, "unknown validation type: '#{@type}'"
        end
      end

      # Verifies that an attribute's value is non-nil and non-empty
      class PresenceValidator < Validator
        # Initialize a presence validator
        def initialize
        end

        # Run the validation to check if <tt>value</tt> is present
        #
        # @return [Cliqr::Validation::Errors] The error wrapper object after the validation has
        # finished
        def validate(name, value, errors)
          errors.add("'#{name}' cannot be nil") if value.nil?
          errors.add("'#{name}' cannot be empty") if value.is_a?(String) && value.empty?
        end
      end

      # Validates the value of an attribute against a regex pattern
      class FormatValidator < Validator
        # Initialize a new format validator
        #
        # @param [Regex] format Format of the value to validate required
        def initialize(format)
          @format = format
        end

        # Run the format validator to check attribute value's format
        #
        # @return [Cliqr::Validation::Errors] The error wrapper object after the validation has
        # finished
        def validate(name, value, errors)
          errors.add("value for '#{name}' must match /#{@format.source}/; " \
                     "actual: #{value.inspect}") \
            if !value.nil? && @format.match(value).nil?
        end
      end

      # Validates that the value of an attribute is of a type that extends from another
      class TypeHierarchyValidator < Validator
        # Create a new instance of type hierarchy validator
        #
        # @param [Class] super_type Class reference that the validated variable must extend from
        def initialize(super_type)
          @super_type = super_type
        end

        # Check if the type of <tt>value</tt> is extensible from a <tt>super_type</tt>
        #
        # @return [Cliqr::Validation::Errors] The error wrapper object after the validation has
        # finished
        def validate(name, value, errors)
          return if value.nil?

          errors.add("value '#{value}' of type '#{value.class.name}' for '#{name}' " \
                     "does not extend from '#{@super_type}'") \
                     unless value < @super_type
        end
      end
    end
  end
end
