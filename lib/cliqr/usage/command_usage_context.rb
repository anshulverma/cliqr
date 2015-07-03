# encoding: utf-8

require 'cliqr/usage/option_usage_context'

module Cliqr
  module Usage
    # The context in which the usage template will be executed
    #
    # @api private
    class CommandUsageContext
      include Cliqr::Command::Color

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
      def initialize(type, config)
        super(config)

        @type = type
        @config = config

        @name = config.name
        @description = config.description
        @actions = @config.actions
                   .map { |action| CommandUsageContext.new(type, action) }
                   .select { |action|  type == :shell ? action.name != 'shell' : true }
        @options = @config.options.map { |option| Usage::OptionUsageContext.new(option) }
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
        @config.arguments == Cliqr::Config::ENABLE_CONFIG
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

      # Check if running inside shell
      def shell?
        @type == :shell
      end

      private

      # Check if a obj is non-empty
      def non_empty?(obj)
        !(obj.nil? || obj.empty?)
      end
    end
  end
end
