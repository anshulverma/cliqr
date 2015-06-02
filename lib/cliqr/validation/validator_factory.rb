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
          NOOPValidator.new(validator_type)
        end
      end

      # Does not validates anything, used by default if a unknown validator type is used
      class Validator
        # Run this validator against an attribute value
        #
        # @param [String] name Name of the attribute
        # @param [Object] value Value of the attribute
        # @param [Cliqr::Validation::Errors] errors Errors after validation finished
        #
        # @return [Boolean] <tt>true</tt> if validation passed
        def validate(name, value, errors)
          validation_sequence(name, value, errors)
        end

        private

        # Recursively validate using parent validator then apply itself
        #
        # @return [Boolean] <tt>true</tt> if validation passed
        def validation_sequence(name, value, errors)
          return false unless validate_parent(name, value, errors)

          local_errors = Errors.new
          @class_stack.last.instance_method(:do_validate).bind(self).call(name, value, local_errors)
          errors.merge(local_errors)
          local_errors.empty?
        end

        # Validate attribute using the parent validator's logic
        #
        # @return [Boolean] <tt>true</tt> if parent class' validation passed
        def validate_parent(name, value, errors)
          @class_stack = (@class_stack || [self.class])
          parent_class = (@class_stack.last || self.class).superclass
          @class_stack.push(parent_class)
          begin
            return parent_class.instance_method(:validate).bind(self) \
              .call(name, value, errors) if parent_class < Validator
            true
          ensure
            @class_stack.pop
          end
        end
      end

      # This is used in case a unknown validation is used
      class NOOPValidator < Validator
        # Initialize a new no-op validator
        def initialize(type)
          @type = type
        end

        # Fails if invoked
        #
        # @return [Object]
        def do_validate(_name, _value, _errors)
          fail Cliqr::Error::UnknownValidatorType, "unknown validation type: '#{@type}'"
        end
      end

      # Verifies that an attribute's value is non-nil and non-empty
      class PresenceValidator < Validator
        protected

        # Validate presence of a attribute's value
        #
        # @return [Cliqr::Validation::Errors] Errors after the validation has finished
        def do_validate(name, value, errors)
          errors.add("'#{name}' cannot be nil") if value.nil?
          errors.add("'#{name}' cannot be empty") if value.is_a?(String) && value.empty?
        end
      end

      # Validates the value of an attribute against a regex pattern
      class FormatValidator < PresenceValidator
        # Initialize a new format validator
        #
        # @param [Regex] format Format of the value to validate required
        def initialize(format)
          @format = format
        end

        protected

        # Run the format validator to check attribute value's format
        #
        # @return [Boolean] <tt>true</tt> if there were any errors during validation
        def do_validate(name, value, errors)
          errors.add("value for '#{name}' must match /#{@format.source}/; " \
                     "actual: #{value.inspect}") \
              if !value.nil? && @format.match(value).nil?
        end
      end

      # Validates that the value of an attribute is of a type that extends from another
      class TypeHierarchyValidator < PresenceValidator
        # Create a new instance of type hierarchy validator
        #
        # @param [Class] super_type Class reference that the validated variable must extend from
        def initialize(super_type)
          @super_type = super_type
        end

        # Check if the type of <tt>value</tt> is extensible from a <tt>super_type</tt>
        #
        # @return [Boolean] <tt>true</tt> if there were any errors during validation
        def do_validate(name, value, errors)
          errors.add("value '#{value}' of type '#{value.class.name}' for '#{name}' " \
                     "does not extend from '#{@super_type}'") \
                           unless value < @super_type
        end
      end
    end
  end
end
