# encoding: utf-8

module Cliqr
  module Usage
    # Wrapper of [Cliqr::CLI::OptionConfig] to be used in usage rendering
    #
    # @api private
    class OptionUsageContext
      # Name of the option
      #
      # @return [String]
      attr_reader :name

      # Short name of the option
      #
      # @return [String]
      attr_reader :short

      # Option's type
      #
      # @return [Symbol]
      attr_reader :type

      # Option's description
      #
      # @return [String]
      attr_reader :description

      # Default value for this option
      #
      # @return [Object]
      attr_reader :default

      # Create a new option usage context
      def initialize(option_config)
        @option_config = option_config

        @name = @option_config.name
        @short = @option_config.short
        @type = @option_config.type
        @description = @option_config.description
        @default = @option_config.default
      end

      # Check if current option is a boolean option
      def boolean?
        @option_config.boolean? && !help? && !version?
      end

      # Check if the option has a short name
      def short?
        @option_config.short?
      end

      # Check if the option has non-empty description
      def description?
        @option_config.description?
      end

      # Assert if the details of this options should be printed
      def details?
        @option_config.description? || @option_config.type? || @option_config.default?
      end

      # Check if the option has a non-default type
      def type?
        @option_config.type? && !help? && !version?
      end

      # check if the option should display default setting
      def default?
        @option_config.default? && !help? && !version?
      end

      # Check if the option is for getting help
      def help?
        @option_config.name == 'help'
      end

      # Check if the option is for version
      def version?
        @option_config.name == 'version'
      end
    end
  end
end
