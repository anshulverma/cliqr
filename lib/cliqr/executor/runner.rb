# encoding: utf-8

require 'cliqr/argument_validation/validator'
require 'cliqr/parser/argument_parser'
require 'cliqr/command/command_context'
require 'cliqr/executor/router'

module Cliqr
  # Handles command execution with error handling
  #
  # @api private
  module Executor
    # The command runner that handles errors as well
    class Runner
      # Create a new command runner
      def initialize(config)
        @config = config
        @validator = Cliqr::ArgumentValidation::Validator.new
      end

      # Execute the command
      #
      # @param [Array<String>] args Arguments that will be used to execute the command
      # @param [Hash] options Options for command execution
      #
      # @return [Integer] Exit status of the command execution
      def execute(args, options)
        args = Cliqr::Util.sanitize_args(args, @config)
        action_config, parsed_input = parse(args)
        begin
          command_context = Command::CommandContext.build(action_config, parsed_input, options) \
            do |forwarded_args, forwarded_options|
              execute(forwarded_args, options.merge(forwarded_options))
            end
          Executor::Router.new(action_config).handle(command_context, **options)
        rescue StandardError => e
          raise Cliqr::Error::CommandRuntimeError.new(
            "command '#{action_config.command}' failed", e)
        end
      end

      private

      # Invoke the command line argument parser
      #
      # @param [Array<String>] args List of arguments that needs to parsed
      #
      # @throws [Cliqr::Error::ValidationError] If the input arguments do not satisfy validation
      # criteria
      #
      # @return [Cliqr::Parser::ParsedInput] Parsed [Cliqr::CLI::Config] instance and arguments
      # wrapper
      def parse(args)
        action_config, parsed_input = Parser.parse(@config, args)
        @validator.validate(parsed_input, action_config)
        [action_config, parsed_input]
      end
    end

    # Exit code mapper based on error type
    #
    # @api private
    class ExitCode
      # Get exit code based on type
      #
      # @return [Integer]
      def self.code(type)
        return 0 if type == :success
        return type.class.error_code if type.class.respond_to?(:error_code)
        99
      end
    end
  end
end
