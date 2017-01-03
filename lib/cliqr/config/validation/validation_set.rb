# frozen_string_literal: true
require 'cliqr/config/validation/validator_factory'

module Cliqr
  module Config
    module Validation
      # A collection of configured validators
      #
      # @api private
      class ValidationSet
        # Initialize a new instance of validation set
        def initialize
          @set = {}
        end

        # Add a new validator
        #
        # @param [Symbol] name Name of the validator
        # @param [Object] options Configuration option to initialize the validator
        #
        # @return [Hash] A map of all validators
        def add(name, options)
          @set[name] = \
            Hash[options.map { |type, config| [type, ValidatorFactory.get(type, config)] }]
        end

        # Merge validations form another set
        #
        # @param [Cliqr::Config::Validation::ValidationSet] other
        #
        # @return [Cliqr::Config::Validation::ValidationSet]
        def merge(other)
          other.each { |name, validations| @set[name] = validations }
        end

        # Iterate over each type of validators
        #
        # @return [Object]
        def each_key(&block)
          @set.each_key(&block)
        end

        # Iterate over each validators
        #
        # @return [Cliqr::Config::Validation::ValidatorFactory::Validator]
        def each(&block)
          @set.each(&block)
        end

        # Run the validators for a attribute against its value
        #
        # @param [Symbol] attribute Name of the attribute
        # @param [Object] value Value of the attribute
        # @param [Cliqr::ValidationErrors] errors A collection wrapper for all validation errors
        #
        # @return [Array] All validators that ran for the attribute against the value
        def validate(attribute, value, errors)
          @set[attribute].values.each do |validator|
            validator.validate(attribute, value, errors)
          end
        end
      end
    end
  end
end
