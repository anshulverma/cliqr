# encoding: utf-8

module Cliqr
  module Parser
    # Token handler for parsing a option and its value
    #
    # @api private
    class OptionToken < Token
      # Name of the option token
      #
      # @return [String]
      attr_accessor :name

      # Argument that was used to parse the option name from
      #
      # @return [String]
      attr_accessor :arg

      # Create a new option token. Initial state will be <tt>active</tt>
      #
      # @param [String] name Long name of the option
      # @param [String] arg Value of the option
      #
      # @return [Cliqr::CLI::Parser::OptionToken] A new Token instance
      def initialize(name, arg)
        @name = name
        @arg = arg

        @value = nil
        @active = true
        @type = :option
      end

      # Check if the token handler is active and needs more arguments
      #
      # @return [Boolean] <tt>true</tt> if the token handler is active
      def active?
        @active
      end

      # Append the next argument in the series and set token to inactive
      #
      # @param [String] arg Argument value of the next command line parameter
      #
      # @return [Boolean] Active state of the token handler
      def append(arg)
        @value = arg
        @active = false
      end

      # Get the token representation
      #
      # @return [Hash] A hash of the token parameters and their values
      def build
        {
            :name => @name.to_s,
            :value => @value
        }
      end

      # Called if this token handler was still active once the argument list ends
      #
      # @return [Cliqr::CLI::Parser::OptionToken] Current instance object
      def finalize
        # should not be called
        fail Cliqr::Error::OptionValueMissing, "a value must be defined for option \"#{@arg}\""
      end
    end
  end
end
