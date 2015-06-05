# encoding: utf-8

module Cliqr
  module Parser
    # Token handler for parsing a boolean option
    #
    # @api private
    class BooleanOptionToken < OptionToken
      # Create a new option token to store boolean value
      def initialize(name, arg)
        super(name, arg)
        @value = !arg.to_s.start_with?('--no-')
      end
    end
  end
end
