# encoding: utf-8

require 'cliqr/parser/parsed_input'

module Cliqr
  module Parser
    # Builder for collecting parsed command line arguments that can be used to
    # build a command context
    #
    # @api private
    class ParsedInputBuilder
      # Initialize a new instance
      #
      # @param [Cliqr::CLI::Config] config Configuration settings for the command line interface
      #
      # @return [Cliqr::CLI::Parser::ParsedInputBuilder]
      def initialize(config, action_config)
        @config = config
        @action_config = action_config
        @actions = []
        @options = []
        @option_names = Set.new
        @arguments = []
      end

      # Add a new parsed option token from the list of options
      #
      # @param [Cliqr::CLI::Parser::OptionToken] token A parsed option token from command line
      # arguments
      #
      # @return [Cliqr::Parser::ParsedInputBuilder] Updated input builder
      def add_option_token(token)
        return self unless token.valid?

        add_option_name(token)
        @options.push(token.build)

        self
      end

      # Add a argument to the list of parsed arguments
      #
      # @param [Cliqr::CLI::Parser::ArgumentToken] token Argument token
      #
      # @return [Cliqr::Parser::ParsedInputBuilder] Updated input builder
      def add_argument_token(token)
        @arguments.push(token.arg) if token.valid?
        self
      end

      # Build the hash of parsed command line arguments
      #
      # @return [Cliqr::Parser::ParsedInput] Parsed arguments wrapper
      def build
        ParsedInput.new(:command => @config.name,
                        :actions => @actions,
                        :options => @options,
                        :arguments => @arguments)
      end

      private

      # Add option's name to a list of already added options and fail if duplicate
      #
      # @param [Cliqr::CLI::Parser::Token] token A parsed token from command line arguments
      #
      # @return [Set<String>] Current list of option names
      def add_option_name(token)
        option_config = @action_config.option(token.name)
        old_config = @option_names.add?(option_config.name)
        fail Cliqr::Error::MultipleOptionValues,
             "multiple values for option \"#{token.arg}\"" if old_config.nil?
        @option_names.add(option_config.short) if option_config.short?
        @option_names
      end
    end
  end
end
