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
      # @param [Array<String>] args List of arguments that needs to parsed
      #
      # @return [Hash] Parsed hash of command line arguments
      def walk(args)
        argument_builder = ParsedInputBuilder.new(@config)
        token_factory = TokenFactory.new(@config)
        token = token_factory.get_token
        args.each do |arg|
          token = handle_argument(arg, token, token_factory)
          argument_builder.add_token(token) unless token.active?
        end
        token.finalize if token.active?
        argument_builder.build
      end

      # Handle the next argument in the context of the current token
      #
      # @return [Cliqr::CLI::Parser::Token] The new active token in case <tt>current_token</tt>
      # becomes inactive
      def handle_argument(arg, current_token, token_factory)
        if current_token.active?
          current_token.append(arg)
        else
          token_factory.get_token(arg)
        end
      end
    end
  end
end
