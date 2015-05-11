# encoding: utf-8

require 'cliqr/dsl'

module Cliqr
  # A extension for CLI module to group all config classes
  module CLI
    # A value to initialize configuration attributes with
    UNSET = Object.new

    # The configuration setting to build a cli application with its own dsl
    #
    # @api private
    class Config
      extend Cliqr::DSL

      # Base name of the command
      #
      # @return [String]
      attr_accessor :basename

      # Description for the base command
      #
      # @return [String]
      attr_accessor :description

      # Command handler for the base command
      #
      # @return [Class]
      attr_accessor :handler

      # Array of options applied to the base command
      #
      # @return [Array<OptionConfig>]
      attr_accessor :options

      def initialize
        @basename = UNSET
        @description = UNSET
        @handler = UNSET
        @options = UNSET
      end

      # Finalize config by adding default values for unset values.
      def finalize
        @basename = '' if @basename == UNSET
        @description = '' if @description == UNSET
        @handler = nil if @handler == UNSET
        @options = [] if @options == UNSET
      end

      # Set value for a config option
      #
      # @param [Symbol] name Name of the config parameter
      #
      # @param [Object] value Value for the config parameter
      #
      # @param [Funciton] block Function which populates configuration for a sub-attribute
      def set_config(name, value, &block)
        case name
        when :option
          handle_option value, &block # value is the long name for the option
        else
          handle_config name, value
        end
      end

      private

      # Set value for config option without evaluating a block
      #
      # @param [Symbol] name Name of the config option
      # @param [Object] value Value for the config option
      def handle_config(name, value)
        public_send("#{name}=", value)
      end

      # Add a new option for the command
      #
      # @param [Symbol] name Long name of the option
      #
      # @param [Function] block Populate the option's config in this funciton block
      def handle_option(name, &block)
        option_config = OptionConfig.build(&block)
        option_config.name = name
        @options = [] if @options == UNSET
        @options.push option_config
      end
    end

    # Config attributes for a command's option
    class OptionConfig
      extend Cliqr::DSL

      attr_accessor :name

      attr_accessor :short

      attr_accessor :description

      def initialize
        @name = UNSET
        @short = UNSET
        @description = UNSET
      end

      # Finalize option's config by adding default values for unset values.
      def finalize
        @name = '' if @name == UNSET
        @short = '' if @short == UNSET
        @description = '' if @description == UNSET
      end

      # Set value for command option's attribute
      #
      # @param [Symbol] name Name of the attribute
      #
      # @param [Object] value Value for the attribute
      def set_config(name, value)
        handle_option_config name, value
      end

      private

      # Set value for config option without evaluating a block
      #
      # @param [Symbol] name Name of the config option
      # @param [Object] value Value for the config option
      def handle_option_config(name, value)
        public_send("#{name}=", value)
      end
    end
  end
end
