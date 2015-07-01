# encoding: utf-8

require 'cliqr/validation_errors'
require 'cliqr/config/validation/validator_factory'
require 'cliqr/config/validation/validation_set'

module Cliqr
  module Config
    # Validation framework for the command line interface config definition adopted from
    # lotus/validations by @jodosha
    #
    # @api private
    #
    # @see https://github.com/lotus/validations
    module Validation
      # If a class includes this module, we add a few useful methods to that class
      #
      # @see http://www.ruby-doc.org/core/Module.html#method-i-included
      #
      # @return [Object]
      def self.included(base)
        base.class_eval do
          extend Verifiable
        end
      end

      # Check if the class is valid based on the configured attribute validations
      #
      # @return [Boolean] <tt>true</tt> if there are no validation errors
      def valid?
        validate

        errors.empty?
      end

      # Run the validation against all attribute values
      #
      # @return [Hash] All validated attributed attributes and their values
      def validate
        read_attributes.each do |name, value|
          validations.validate(name, value, errors)
        end
      end

      # Get the list of validations to be performed
      #
      # @return [Hash] A hash of attribute name to its validator
      def validations
        self.class.__send__(:validations)
      end

      # Read current values for all attributes that must be validated
      #
      # @return [Hash] All attributes that must be validated along with their current values
      def read_attributes
        {}.tap do |attributes|
          validations.each_key do |attribute|
            attributes[attribute] = public_send(attribute)
          end
        end
      end

      # Get a list of errors after validation finishes
      #
      # @return [Cliqr::ValidationErrors] A wrapper of all errors
      def errors
        @errors ||= ValidationErrors.new
      end

      # Validations DSL
      module Verifiable
        # Add a new validation for a attribute
        #
        # @param [Symbol] name Name of the attribute to validate
        # @param [Object] options Configuration to initialize a attribute validator with
        #
        # @return [Cliqr::Config::Validation::ValidationSet]
        def validates(name, options)
          validations.add(name, options)
        end

        # Get or create a new <tt>Cliqr::Config::Validation::ValidationSet</tt>
        #
        # @return [Cliqr::Config::Validation::ValidationSet]
        def validations
          @validations ||= ValidationSet.new
        end
      end
    end
  end
end
