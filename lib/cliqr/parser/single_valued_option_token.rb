# frozen_string_literal: true
require 'cliqr/parser/option_token'

module Cliqr
  module Parser
    # Token handler for parsing a option and its value
    #
    # @api private
    class SingleValuedOptionToken < OptionToken
      # Create a new option token. Initial state will be <tt>active</tt>
      def initialize(name, arg)
        super(name, arg)
        activate
      end

      # Append the next argument in the series and set token to inactive
      #
      # @param [String] arg Argument value of the next command line parameter
      #
      # @return [Cliqr::Parser::SingleValuedOptionToken]
      def append(arg)
        @value = arg
        deactivate
        self
      end
    end
  end
end
