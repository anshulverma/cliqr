# frozen_string_literal: true
require 'cliqr/executor/command_runner_factory'

module Cliqr
  module Executor
    # Used for routing the command to the appropriate command handler based on the interface config
    #
    # @api private
    class Router
      # Create a new Router instance
      #
      # @param [Cliqr::Config::Command] config Command line configuration
      #
      # @return [Cliqr::Interface::Router]
      def initialize(config)
        @config = config
      end

      # Handle a command invocation by routing to appropriate command handler
      #
      # @param [Cliqr::CLI::CommandContext] context Context in which to execute the command
      # @param [Hash] options Hash of options to configure the [Cliqr::CLI::CommandRunner]
      #
      # @return [Integer] Exit code of the command execution
      def handle(context, **options)
        handler = @config.handler
        runner = CommandRunnerFactory.get(options)
        runner.run do
          if handler.is_a?(Proc)
            context.instance_eval(&handler)
          else
            handler.execute(context)
          end
        end
      end
    end
  end
end
