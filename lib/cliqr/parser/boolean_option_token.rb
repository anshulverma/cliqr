# encoding: utf-8

module Cliqr
  module Parser
    # Token handler for parsing a boolean option
    #
    # @api private
    class BooleanOptionToken < Token
      # Create a new option token to store boolean value
      def initialize(name, arg)
        super(name, arg)
        @value = !arg.to_s.start_with?('--no-')
      end

      # Get the token representation
      #
      # @return [Hash] A hash of the option name and its value (<tt>true</tt> or <tt>false</tt>)
      def build
        {
            :name => @name.to_s,
            :value => @value
        }
      end
    end
  end
end
