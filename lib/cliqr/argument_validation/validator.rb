# encoding: utf-8

require 'cliqr/error'
require 'cliqr/argument_validation/option_validator'
require 'cliqr/argument_validation/argument_type_validator'

module Cliqr
  # Validate command arguments based on pre-configured settings
  #
  # @api private
  module ArgumentValidation
    # Utiity class to validate input to a command
    #
    # @api private
    class Validator
      # Initialize a new Validator instance
      def initialize
        @option_validators = {}
      end

      # Validate parsed command line arguments
      #
      # @param [Cliqr::Parser::ParsedInput] args Parsed input instance
      #
      # @return [Cliqr::Parser::ParsedInput] Validated parsed input
      def validate(args, config)
        errors = ValidationErrors.new
        config.options.each do |option|
          validate_argument(args.option(option.name), option, errors) \
            if args.options.key?(option.name.to_s)
        end
        fail(Cliqr::Error::IllegalArgumentError, "illegal argument error - #{errors}") \
          unless errors.empty?
        args
      end

      private

      # Validate a argument for an option and return errors
      #
      # @return [Cliqr::ValidationErrors]
      def validate_argument(argument, option, errors)
        option_validator = get_option_validator(option)
        option_validator.validate(argument, option, errors)
        errors
      end

      # Get or create validator for a option
      #
      # @return [Hash] A hash of all option mapped to its validator
      def get_option_validator(option)
        @option_validators[option] = build_option_validator(option) \
          unless @option_validators.key?(option)
        @option_validators[option]
      end

      # Create a new option validator
      #
      # @return [Cliqr::ArgumentValidation::OptionValidator]
      def build_option_validator(option)
        option_validator = OptionValidator.new
        option_validator.add(ArgumentTypeValidator.new) if option.type?
        option_validator
      end
    end
  end
end
