# encoding: utf-8

require 'cliqr/parser/parsed_input_builder'
require 'cliqr/parser/token_factory'

module Cliqr
  module Parser
    # Walks the list of arguments and parses them one token at a time
    #
    # @api private
    class ArgumentTreeWalker
      # Create a new instance
      #
      # @param [Cliqr::CLI::Config] config Configuration settings for the command line interface
      #
      # @return [Cliqr::CLI::Parser::ArgumentTreeWalker]
      def initialize(config)
        @config = config
      end

      # Parse the arguments and generate tokens by iterating over command line arguments
      #
      # @param [Array<String>] raw_args List of arguments that needs to parsed
      #
      # @return [Hash] Parsed hash of command line arguments
      def walk(raw_args)
        action_config, args = parse_action(raw_args)
        input_builder = ParsedInputBuilder.new(@config, action_config)
        token_factory = TokenFactory.new(action_config)
        token = token_factory.get_token
        args.each do |arg|
          token = handle_argument(arg, token, token_factory, input_builder)
        end
        fail Cliqr::Error::OptionValueMissing, \
             "a value must be defined for argument \"#{token.arg}\"" if token.active?
        [action_config, input_builder.build]
      end

      private

      # Parse the action from the list of arguments
      #
      # @return [Cliqr::CLI::Config] Configuration of the command invoked and remaining arguments
      def parse_action(raw_args)
        args = []
        action_config = @config
        raw_args.each do |arg|
          if action_config.action?(arg)
            action_config = action_config.action(arg)
          else
            args.push(arg)
          end
        end
        [action_config, args]
      end

      # Handle the next argument in the context of the current token
      #
      # @return [Cliqr::CLI::Parser::Token] The new active token in case <tt>current_token</tt>
      # becomes inactive
      def handle_argument(arg, current_token, token_factory, input_builder)
        if current_token.active?
          token = current_token.append(arg)
        else
          token = token_factory.get_token(arg)
        end

        token.collect(input_builder)

        token
      end
    end
  end
end
