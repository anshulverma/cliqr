# encoding: utf-8

module Cliqr
  module Parser
    # A NO-OP argument token
    #
    # @api private
    class Token
      # Argument that was used to parse this token
      #
      # @return [String]
      attr_accessor :arg

      # Create a new token
      #
      # @param [String] arg Value of the option
      def initialize(arg = nil)
        @arg = arg

        @active = false
      end

      # Get activation status of this token
      #
      # @return [Boolean] This will always return <tt>false</tt> in this case
      def active?
        @active
      end

      # Collect this token's argument into a input builder
      #
      # @param [Cliqr::Parser::ParsedInputBuilder] input_builder A builder to prepare parsed
      # arguments
      #
      # @return [Cliqr::Parser::ParsedInputBuilder] The updated input builder instance
      def collect(input_builder)
        input_builder.add_argument_token(self)
      end

      protected

      # Activate this token so that it can consume more arguments
      #
      # @return [Boolean] Token activation state
      def activate
        @active = true
      end

      # Deactivate this token to indicate that it does not need more arguments
      #
      # @return [Boolean] Token activation state
      def deactivate
        @active = false
      end
    end
  end
end
