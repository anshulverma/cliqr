# encoding: utf-8

require 'cliqr/util'
require 'cliqr/command/base_command'
require 'cliqr/config/base'
require 'cliqr/config/option'

module Cliqr
  module Config
    # Configuration setting for an option based setting
    #
    # @api private
    class OptionBased < Cliqr::Config::Named
      # Array of options applied to the base command
      #
      # @return [Array<OptionConfig>]
      attr_accessor :options
      validates :options,
                hash: true

      # New config instance with all attributes set as UNSET
      def initialize
        super

        @options = {}
        @short_option_index = {}
      end

      # Finalize config by adding default values for unset values
      #
      # @return [Cliqr::Config::OptionBased]
      def finalize
        super

        if options? && @short_option_index.empty?
          @options.values.each do |option|
            @short_option_index[option.short.to_s] = option if option.short?
          end
        end

        self
      end

      # Set value for a config option
      #
      # @param [Symbol] name Name of the config parameter
      # @param [Object] value Value for the config parameter
      # @param [Proc] block Function which populates configuration for a sub-attribute
      #
      # @return [Cliqr::Config::Option] Newly added option config
      def set_config(name, value, *args, &block)
        case name
        when :option
          handle_option(value, &block) # value is the long name for the option
        else
          super
        end
      end

      # Check if options are set
      def options?
        return false if @options.nil?
        !@options.empty?
      end

      # Check if particular option is set
      #
      # @param [String] name Name of the option to check
      def option?(name)
        @options.key?(name.to_s) || @short_option_index.key?(name.to_s)
      end

      # Get value of a option
      #
      # @param [String] name Name of the option
      #
      # @return [String] value for the option
      def option(name)
        if @options.key?(name.to_s)
          @options[name.to_s]
        else
          @short_option_index[name.to_s]
        end
      end

      private

      # Handle configuration for a new option
      #
      # @param [Symbol] name Long name of the option
      # @param [Proc] block Populate the option's config in this function block
      #
      # @return [Cliqr::Config::Option] Newly created option's config
      def handle_option(name, &block)
        option_config = Option.build(&block)
        option_config.name = name
        add_option(option_config)
      end

      # Add a new option for the command
      #
      # @return [Cliqr::Config::Option] Newly added option's config
      def add_option(option_config)
        validate_option_name(option_config)

        @options[option_config.name.to_s] = option_config
        @short_option_index[option_config.short.to_s] = option_config if option_config.short?

        option_config
      end

      # Make sure that the option's name is unique
      #
      # @param [Cliqr::Config::Option] option_config Config for this particular option
      #
      # @return [Cliqr::Config::Option] Validated OptionConfig instance
      def validate_option_name(option_config)
        fail Cliqr::Error::DuplicateOptions,
             "multiple options with long name \"#{option_config.name}\"" \
             if option?(option_config.name)

        fail Cliqr::Error::DuplicateOptions,
             "multiple options with short name \"#{option_config.short}\"" \
              if option?(option_config.short)

        option_config
      end
    end
  end
end
