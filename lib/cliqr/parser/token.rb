# encoding: utf-8

module Cliqr
  module Parser
    # A NO-OP argument token
    #
    # @api private
    class Token
      # Name of the option token
      #
      # @return [String]
      attr_accessor :name

      # Argument that was used to parse the option name from
      #
      # @return [String]
      attr_accessor :arg

      # Create a new option token
      #
      # @param [String] name Long name of the option
      # @param [String] arg Value of the option
      #
      # @return [Cliqr::CLI::Parser::OptionToken] A new Token instance
      def initialize(name = nil, arg = nil)
        @name = name
        @arg = arg
      end

      # This token is never active
      #
      # @return [Boolean] This will always return <tt>false</tt> in this case
      def active?
        false
      end

      # A token is not valid if it does not have a name
      #
      # @return [Boolean] <tt>false</tt> if the token's name is nil
      def valid?
        !@name.nil?
      end
    end
  end
end
