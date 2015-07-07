# encoding: utf-8

module Cliqr
  module Config
    module Validation
      # A factory class to retrieve a attribute validator based on the configuration type
      #
      # @api private
      module ValidatorFactory
        # Does not validates anything, used by default if a unknown validator type is used
        class Validator
          # Run this validator against an attribute value
          #
          # @param [String] name Name of the attribute
          # @param [Object] value Value of the attribute
          # @param [Cliqr::ValidationErrors] errors Errors after validation finished
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

            local_errors = ValidationErrors.new
            @class_stack.last.instance_method(:do_validate).bind(self)
              .call(name, value, local_errors)
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

          protected

          # Fails if invoked
          #
          # @return [Object]
          def do_validate(_name, _value, _errors)
            fail Cliqr::Error::UnknownValidatorType, "unknown validation type: '#{@type}'"
          end
        end

        # Verifies that an attribute's value is non-nil
        class NonNilValidator < Validator
          # Initialize a new non-nil validator
          def initialize(enabled)
            @enabled = enabled
          end

          protected

          # Validate presence of an attribute's value
          #
          # @return [Cliqr::ValidationErrors] Errors after the validation has finished
          def do_validate(name, value, errors)
            errors.add("'#{name}' cannot be nil") if @enabled && value.nil?
            errors
          end
        end

        # Verifies that an attribute's value is non-empty
        class NonEmptyValidator < NonNilValidator
          # Create a new non-empty validator
          def initialize(enabled)
            super(enabled)
            @enabled = enabled
          end

          protected

          # Validate that a attribute's value is not empty
          #
          # @return [Cliqr::ValidationErrors] Errors after the validation has finished
          def do_validate(name, value, errors)
            errors.add("'#{name}' cannot be empty") \
              if @enabled && value.respond_to?(:empty?) && value.empty?
            errors
          end
        end

        # Validates the value of an attribute against a regex pattern
        class FormatValidator < NonNilValidator
          # Initialize a new format validator
          #
          # @param [Regex] format Format of the value to validate required
          def initialize(format)
            super(true)
            @format = format
          end

          protected

          # Run the format validator to check attribute value's format
          #
          # @return [Boolean] <tt>true</tt> if there were any errors during validation
          def do_validate(name, value, errors)
            errors.add("value for '#{name}' must match /#{@format.source}/; " \
                       "actual: #{value.inspect}") \
                if !value.nil? && !match?(value)
            errors
          end

          # Check if the value matches a particular format
          def match?(value)
            return false unless value.is_a?(String) || value.is_a?(Symbol)
            !@format.match(value).nil?
          end
        end

        # Validates that a value matches a pattern and it is not empty
        class NonEmptyFormatValidator < NonEmptyValidator
          # Initialize a new non-empty format validator
          #
          # @param [Regex] format Format of the value to validate required
          def initialize(format)
            super(true)
            @format = format
          end

          protected

          # Run the format validator along with non-empty check
          #
          # @return [Boolean] <tt>true</tt> if there were any errors during validation
          def do_validate(name, value, errors)
            FormatValidator.new(@format).validate(name, value, errors)
          end
        end

        # Validates that a value matches a pattern and it is not empty; nil value allowed
        class NonEmptyNilOkFormatValidator < Validator
          # Initialize a new non-empty-nil-ok format validator
          #
          # @param [Regex] format Format of the value to validate required
          def initialize(format)
            @format = format
          end

          protected

          # Run the validator
          #
          # @return [Boolean] <tt>true</tt> if there were any errors during validation
          def do_validate(name, value, errors)
            unless value.nil?
              local_errors = ValidationErrors.new
              local_errors.add("'#{name}' cannot be empty") \
                if value.respond_to?(:empty?) && value.empty?
              FormatValidator.new(@format).validate(name, value, local_errors) \
                if local_errors.empty?
              errors.merge(local_errors)
            end
            errors
          end
        end

        # Validates that the value of an attribute is of a type that extends from another
        class TypeHierarchyValidator < NonNilValidator
          # Create a new instance of type hierarchy validator
          #
          # @param [Class] super_type Class reference that the validated variable must extend from
          def initialize(super_type)
            super(true)
            @super_type = super_type
          end

          protected

          # Check if the type of <tt>value</tt> is extensible from a <tt>super_type</tt>
          #
          # @return [Boolean] <tt>true</tt> if there were any errors during validation
          def do_validate(name, value, errors)
            begin
              return if value.is_a?(@super_type) || \
                        (value.respond_to?(:<) ? value < @super_type : value.is_a?(@super_type))
            rescue ArgumentError
              # the comparison failed which indicates that the validation also failed
            end
            errors.add("#{name} of type '#{value.class.name}' " \
                       "does not extend from '#{@super_type}'")
          end
        end

        # Validates each element inside a collection
        class CollectionValidator < TypeHierarchyValidator
          # Create a new collection validator
          def initialize(_config, type = nil)
            super(type || Array)
          end

          protected

          # Validate each element inside a collection and prepend index to error
          #
          # @return [Boolean] <tt>true</tt> if there were any errors during validation
          def do_validate(name, values, errors)
            valid = true
            iterator(values) do |value, key|
              valid = false unless value.valid?
              value.errors.each do |error|
                if value.name.nil? || value.name.empty?
                  errors.add("#{name}[#{key}] - #{error}")
                else
                  errors.add("#{name.to_s.gsub(/s$/, '')} \"#{value.name}\" - #{error}")
                end
              end
            end
            valid
          end

          # Iterator for each item in the array
          #
          # @return [Array]
          def iterator(array, &block)
            array.each_with_index do |value, index|
              block.call(value, index + 1) unless value.skip_validation?
            end
          end
        end

        # Validates each element inside a hash map
        class HashValidator < CollectionValidator
          # Create a new hash validator
          def initialize(config)
            super(config, Hash)
          end

          protected

          # Validate each element inside a hash and prepend key to error
          #
          # @return [Boolean] <tt>true</tt> if there were any errors during validation
          def do_validate(_name, _values, _errors)
            true
          end

          # Iterate over each key value pair in the hash
          #
          # @return [Hash]
          def iterator(hash, &block)
            hash.each_with_index do |(key, value), index|
              block.call(value, key.empty? ? (index + 1) : key)
            end
          end
        end

        # Validate that a attribute value is included in a predefined set
        class InclusionValidator < NonNilValidator
          # Create a new inclusion validator
          #
          # @param [Array<Symbol>] allowed_values A set of allowed values
          def initialize(allowed_values)
            @allowed_values = allowed_values
          end

          protected

          # Validate that a value is included in <tt>allowed_values</tt>
          #
          # @return [Nothing]
          def do_validate(_name, value, errors)
            errors.add("invalid type '#{value}'") unless @allowed_values.include?(value)
          end
        end

        # Validate the type of a attribute's value
        class TypeOfValidator < NonNilValidator
          # Create a new <tt>:type_of</tt> validator
          def initialize(type)
            super(true)
            @type = type
          end

          protected

          # Run the <tt>:type_of</tt> validation check
          #
          # @return [Nothing]
          def do_validate(name, value, errors)
            errors.add("#{name} should be a '#{@type}' not '#{value.class}'") \
              unless matches?(value)
          end

          # Check if a value matches a type
          def matches?(value)
            begin
              return true if value.class == @type
              return value < @type if value.respond_to?(:<)
            rescue ArgumentError
              # nothing to do here just return false below
            end
            false
          end
        end

        # Run multiple validators on a value to assert at-least one of them passes
        class OneOfValidator < Validator
          # Create a new <tt>:one_of</tt> validator
          def initialize(validator_configs)
            @validators = []
            validator_configs.each do |config|
              @validators.push(ValidatorFactory.get(config.first[0], config.first[1]))
            end
          end

          protected

          # Run each validator one by one until one passes
          #
          # @return [Nothing]
          def do_validate(name, value, errors)
            local_errors = ValidationErrors.new
            passing_validator = @validators.find do |validator|
              validator_errors = ValidationErrors.new.tap do |temp_errors|
                validator.validate(name, value, temp_errors)
                local_errors.merge(temp_errors)
              end
              validator_errors.empty?
            end
            errors.add("invalid value for #{name}; fix one of - [#{local_errors}]") \
              if passing_validator.nil?
          end
        end

        # Validates child element
        class ChildValidator < Validator
          # Create a new child validator
          def initialize(_config)
          end

          protected

          # Validate the child element
          #
          # @return [Boolean] <tt>true</tt> if there were any errors during validation
          def do_validate(name, value, errors)
            return true if value.valid?
            value.errors.each do |error|
              errors.add("#{name} - #{error}")
            end
            false
          end
        end

        # A hash of validator type id to validator class
        VALIDATORS = {
            :non_empty => NonEmptyValidator,
            :non_empty_format => NonEmptyFormatValidator,
            :non_empty_nil_ok_format => NonEmptyNilOkFormatValidator,
            :format => FormatValidator,
            :extend => TypeHierarchyValidator,
            :collection => CollectionValidator,
            :hash => HashValidator,
            :inclusion => InclusionValidator,
            :one_of => OneOfValidator,
            :type_of => TypeOfValidator,
            :child => ChildValidator
        }

        # Get a new validator based on the type and config param
        #
        # @return [Cliqr::Validation::ValidatorFactory::Validator]
        def self.get(validator_type, config)
          validator_class = VALIDATORS[validator_type]
          if validator_class.nil?
            NOOPValidator.new(validator_type)
          else
            validator_class.new(config)
          end
        end
      end
    end
  end
end
