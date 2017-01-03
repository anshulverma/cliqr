# frozen_string_literal: true
module Cliqr
  module Parser
    # Token handler for parsing a arbitrary argument value
    #
    # @api private
    class ArgumentToken < Token
      # Create a new argument token
      def initialize(arg)
        super(arg)
      end

      # This token is valid if argument is non-empty
      #
      # @return [Boolean] <tt>true</tt> if token's argument is non-empty
      def valid?
        return false if arg.nil?
        !arg.empty?
      end
    end
  end
end
