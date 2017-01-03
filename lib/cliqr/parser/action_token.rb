# frozen_string_literal: true
module Cliqr
  module Parser
    # Token handler for parsing action commands
    #
    # @api private
    class ActionToken < Token
      # Create a new action token
      def initialize(_name)
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
