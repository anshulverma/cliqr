# encoding: utf-8

module Cliqr
  module Parser
    # Token handler for parsing a option and its value
    #
    # @api private
    class SingleValuedOptionToken < Token
      # Create a new option token. Initial state will be <tt>active</tt>
      def initialize(name, arg)
        super(name, arg)
        @value = nil
        @active = true
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
      # @return [Cliqr::Parser::SingleValuedOptionToken]
      def append(arg)
        @value = arg
        @active = false
        self
      end

      # Get the token representation
      #
      # @return [Hash] Token name and value in a hash
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
