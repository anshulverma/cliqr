# encoding: utf-8

require 'cliqr/validation/validator_factory'

module Cliqr
  module Validation
    # A collection of configured validators
    #
    # @api private
    class ValidationSet
      # Initialize a new instance of validation set
      def initialize
        @validations = {}
      end

      # Add a new validator
      #
      # @param [Symbol] name Name of the validator
      # @param [Object] options Configuration option to initialize the validator
      #
      # @return [Hash] A map of all validators
      def add(name, options)
        @validations[name] = \
          Hash[options.map { |type, config| [type, ValidatorFactory.get(type, config)] }]
      end

      # Iterate over each type of validators
      #
      # @return [Object]
      def each_key(&block)
        @validations.each_key(&block)
      end

      # Run the validators for a attribute against its value
      #
      # @param [Symbol] attribute Name of the attribute
      # @param [Object] value Value of the attribute
      # @param [Cliqr::Validation::Errors] errors A collection wrapper for all validation errors
      #
      # @return [Array] All validators that ran for the attribute against the value
      def validate(attribute, value, errors)
        @validations[attribute].values.each do |validator|
          validator.validate(attribute, value, errors)
        end
      end
    end
  end
end
