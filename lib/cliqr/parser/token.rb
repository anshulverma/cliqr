# encoding: utf-8

module Cliqr
  module Parser
    # A NO-OP argument token
    #
    # @api private
    class Token
      # Type of the token handler (:option in this case)
      #
      # @return [Symbol]
      attr_accessor :type

      # Create a new NO OP token
      #
      # @return [Cliqr::CLI::Parser::Token]
      def initialize
        @type = :NO_OP
      end

      # This token is never active
      #
      # @return [Boolean] This will always return <tt>false</tt> in this case
      def active?
        false
      end

      # Called if this token was still active once the argument list ends
      #
      # @return [Cliqr::CLI::Parser::TokenHandler] Current instance object
      def finalize
        self
      end
    end
  end
end
