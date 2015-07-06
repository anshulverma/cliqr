# encoding: utf-8

require 'cliqr/config/dsl'
require 'cliqr/config/validation/verifiable'

module Cliqr
  # A extension for CLI module to group all config classes
  #
  # @api private
  module Config
    # A value to initialize configuration attributes with
    UNSET = Object.new

    # Configuration option to enable arguments for a command (default)
    ENABLE_CONFIG = :enable

    # Configuration option to disable arguments for a command
    DISABLE_CONFIG = :disable

    # Option type for regular options
    ANY_ARGUMENT_TYPE = :any

    # Option type for numeric arguments
    NUMERIC_ARGUMENT_TYPE = :numeric

    # Option type for boolean arguments
    BOOLEAN_ARGUMENT_TYPE = :boolean

    # Default values based on argument type
    ARGUMENT_DEFAULTS = {
        NUMERIC_ARGUMENT_TYPE => 0,
        BOOLEAN_ARGUMENT_TYPE => false,
        ANY_ARGUMENT_TYPE => nil
    }

    # Get the passed param value if current attribute is unset
    #
    # @return [Object]
    def self.get_if_unset(attribute_value, default_value)
      attribute_value == UNSET ? default_value : attribute_value
    end

    # The base configuration setting to build a cli application with its own dsl
    class Base
      include Cliqr::Config::DSL
      include Cliqr::Config::Validation

      # Set value for an attribute
      #
      # @param [Symbol] name Name of the config parameter
      # @param [Object] value Value for the config parameter
      # @param [Proc] block Function which populates configuration for a sub-attribute
      #
      # @return [Object] new attribute's value
      def set_config(name, value, *_args, &block)
        value = block if block_given?
        handle_config(name, value)
      end

      private

      # Set value for an attribute by evaluating a block
      #
      # @param [Symbol] name Name of the config option
      # @param [Object] value Value for the config option
      #
      # @return [Object]
      def handle_config(name, value)
        public_send("#{name}=", value)
        value
      end
    end
  end
end
