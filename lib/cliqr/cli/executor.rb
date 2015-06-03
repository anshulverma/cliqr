# encoding: utf-8

require 'cliqr/cli/router'
require 'cliqr/cli/command_context'
require 'cliqr/cli/argument_validator'
require 'cliqr/parser/argument_parser'

module Cliqr
  module CLI
    # Handles command execution with error handling
    #
    # @api private
    class Executor
      # Create a new command executor
      def initialize(config)
        @config = config
        @router = Router.new(config)
        @validator = ArgumentValidator.new
      end

      # Execute the command
      #
      # @param [Array<String>] args Arguments that will be used to execute the command
      # @param [Hash] options Options for command execution
      #
      # @return [Integer] Exit status of the command execution
      def execute(args, options)
        command_context = CommandContext.build(parse(args))
        @router.handle command_context, **options
      rescue StandardError => e
        raise Cliqr::Error::CommandRuntimeException.new("command '#{@config.basename}' failed", e)
      end

      private

      # Invoke the command line argument parser
      #
      # @param [Array<String>] args List of arguments that needs to parsed
      #
      # @return [Hash] Parsed hash of command line arguments
      def parse(args)
        parsed_args = Parser.parse(@config, args)
        @validator.validate(parsed_args)
        parsed_args
      end
    end
  end
end
