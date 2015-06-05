# encoding: utf-8

require 'cliqr/parser/token'
require 'cliqr/parser/single_valued_option_token'
require 'cliqr/parser/boolean_option_token'
require 'cliqr/parser/argument_token'

module Cliqr
  module Parser
    # A factory class to get a instance of {Cliqr::CLI::Parser::Token}
    # based on the argument
    #
    # @api private
    class TokenFactory
      # Create a new token factory instance
      #
      # @param [Cliqr::CLI::Config] config Command line interface configuration
      #
      # @return [Cliqr::CLI::Parser::TokenFactory]
      def initialize(config)
        @config = config
      end

      # Get a new instance of {Cliqr::CLI::Parser::Token} based on the argument
      #
      # @param [String] arg The argument used to get a token instance (default nil)
      #
      # @return [Cliqr::CLI::Parser::Token]
      def get_token(arg = nil)
        if arg.nil?
          Token.new
        else
          case arg
          when /^--(no-)?([a-zA-Z][a-zA-Z0-9\-_]*)$/, /^(-)([a-zA-Z])$/
            option_config = get_option_config(Regexp.last_match(2), arg)
            build_token(option_config, arg)
          else
            fail Cliqr::Error::InvalidArgumentError, "invalid command argument \"#{arg}\"" \
              unless @config.arguments?
            ArgumentToken.new(arg)
          end
        end
      end

      private

      # Build a option token handler based on the option's config
      #
      # @return [Cliqr::CLI::Parser::Token]
      def build_token(option_config, arg)
        case option_config.type
        when :boolean
          BooleanOptionToken.new(option_config.name, arg)
        else
          SingleValuedOptionToken.new(option_config.name, arg)
        end
      end

      # Check if a option is defined with the requested name then return it
      #
      # @param [String] name Long name of the option
      # @param [String] arg THe argument that was parsed to get the option name
      #
      # @return [Cliqr::CLI::OptionConfig] Requested option configuration
      def get_option_config(name, arg)
        fail Cliqr::Error::UnknownCommandOption,
             "unknown option \"#{arg}\"" unless @config.option?(name)
        @config.option(name)
      end
    end
  end
end
