# encoding: utf-8

require 'cliqr/cli/router'
require 'cliqr/cli/command_context'
require 'cliqr/argument_validation/validator'
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
        @validator = Cliqr::ArgumentValidation::Validator.new
      end

      # Execute the command
      #
      # @param [Array<String>] args Arguments that will be used to execute the command
      # @param [Hash] options Options for command execution
      #
      # @return [Integer] Exit status of the command execution
      def execute(args, options)
        parsed_input = parse(args)
        begin
          command_context = CommandContext.build(parsed_input)
          @router.handle command_context, **options
        rescue StandardError => e
          raise Cliqr::Error::CommandRuntimeException.new("command '#{@config.basename}' failed", e)
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
      # @return [Cliqr::Parser::ParsedInput] Parsed arguments wrapper
      def parse(args)
        parsed_input = Parser.parse(@config, args)
        @validator.validate(parsed_input, @config)
        parsed_input
      end
    end
  end
end
