# encoding: utf-8

require 'cliqr/error'
require 'cliqr/cli/executor'

module Cliqr
  module CLI
    # Builds the usage information based on the configuration settings
    #
    # @api private
    class UsageBuilder
      # Build the usage information
      #
      # @param [Cliqr::CLI::Config] config Configuration of the command line interface
      #
      # @return [String]
      def self.build(config)
        template_file_path = File.expand_path('../../../../templates/usage.erb', __FILE__)
        template = ERB.new(File.new(template_file_path).read, nil, '%')
        usage_context = CommandUsageContext.new(config)
        result = template.result(usage_context.instance_eval { binding })

        # remove multiple newlines from the end of usage
        "#{result.strip}\n"
      end
    end

    # The context in which the usage template will be executed
    #
    # @api private
    class CommandUsageContext
      # Name of the current command in context
      #
      # @return [String]
      attr_reader :name

      # Description of the current command
      #
      # @return [String]
      attr_reader :description

      # Pre-configured command's actions
      #
      # @return [Array<Cliqr::CLI::CommandUsageContext>]
      attr_reader :actions

      # List of options configured for current context
      #
      # @return [Array<Cliqr::CLI::OptionUsageContext>]
      attr_reader :options

      # Command for the current context
      #
      # @return [String]
      attr_reader :command

      # Wrap a [Cliqr::CLI::Config] instance for usage template
      def initialize(config)
        @config = config

        @name = config.name
        @description = config.description
        @actions = @config.actions.map { |action| CommandUsageContext.new(action) }
        @options = @config.options.map { |option| OptionUsageContext.new(option) }
        @command = @config.command
      end

      # Check if command has a description
      def description?
        non_empty?(@description)
      end

      # Check if there are any preconfigured options
      def options?
        non_empty?(@config.options)
      end

      # Check if current command allows arguments
      def arguments?
        @config.arguments == Cliqr::CLI::ENABLE_CONFIG
      end

      # Check if current command has any actions
      def actions?
        non_empty?(@actions)
      end

      # Check if the help is enabled
      #
      # @return [Boolean]
      def help?
        @config.help?
      end

      private

      # Check if a obj is non-empty
      def non_empty?(obj)
        !(obj.nil? || obj.empty?)
      end
    end

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
