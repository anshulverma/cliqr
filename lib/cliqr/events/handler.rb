# frozen_string_literal: true
module Cliqr
  # Set of classes to manage and facilitate event handling
  #
  # @api private
  module Events
    # Event handler that all event handlers come from
    class Handler
      # Create a instance of event handler
      def initialize(context)
        @context = context
      end

      # Handle a incoming event needs to be implemented in a subclass
      #
      # @throws [Cliqr::Error::InvocationError]
      #
      # @return [Nothing]
      def handle(*_args)
        raise Cliqr::Error::InvocationError, 'handle method not implemented by handler class'
      end

      # Invoker another event
      #
      # @return [Boolean]
      def invoke(*args)
        @context.invoke(*args)
      end
    end
  end
end
