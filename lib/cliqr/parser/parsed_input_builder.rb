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
      def initialize(config)
        @config = config
        @options = []
        @option_names = Set.new
      end

      # Add a new parsed token from the list of arguments
      #
      # @param [Cliqr::CLI::Parser::Token] token A parsed token from command line arguments
      #
      # @return [Boolean] <tt>true</tt> if the token was added
      def add_token(token)
        case token.type
        when :option
          add_option_name(token)
          @options.push(token.build)
        else
          return false
        end
        true
      end

      # Build the hash of parsed command line arguments
      #
      # @return [Cliqr::Parser::ParsedInput] Parsed arguments wrapper
      def build
        ParsedInput.new(:command => @config.basename,
                        :options => @options)
      end

      private

      # Add option's name to a list of already added options and fail if duplicate
      #
      # @param [Cliqr::CLI::Parser::Token] token A parsed token from command line arguments
      #
      # @return [Set<String>] Current list of option names
      def add_option_name(token)
        option_config = @config.option(token.name)
        old_config = @option_names.add?(option_config.name)
        fail Cliqr::Error::MultipleOptionValues,
             "multiple values for option \"#{token.arg}\"" if old_config.nil?
        @option_names.add(option_config.short) if option_config.short?
        @option_names
      end
    end
  end
end
