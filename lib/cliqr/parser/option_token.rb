# encoding: utf-8

module Cliqr
  module Parser
    # Represents a option token
    #
    # @api private
    class OptionToken < Token
      # Name of the option token
      #
      # @return [String]
      attr_accessor :name

      # Value of the option token
      #
      # @return [String]
      attr_accessor :value

      # Create a new option token with a name and value
      #
      # @param [String] name Long name of the option
      # @param [String] arg Argument used to parse option name
      def initialize(name, arg)
        super(arg)

        @name = name
        # @value = value
      end

      # Get the token representation
      #
      # @return [Hash] A hash of the option name and its value
      def build
        {
            :name => @name.to_s,
            :value => @value
        }
      end

      # A option token is not valid if it does not have a name
      #
      # @return [Boolean] <tt>false</tt> if the token's name is nil
      def valid?
        !@name.nil?
      end

      # Collect this token's name and value into a input builder
      #
      # @param [Cliqr::Parser::ParsedInputBuilder] input_builder A builder to prepare parsed
      # arguments
      #
      # @return [Cliqr::Parser::ParsedInputBuilder] The updated input builder instance
      def collect(input_builder)
        input_builder.add_option_token(self) unless active?
      end
    end
  end
end
