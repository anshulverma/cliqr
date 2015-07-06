# encoding: utf-8

module Cliqr
  module Events
    # The context in which event handlers are invoked
    #
    # @api private
    class EventContext
      # Create a new event context to execute events
      def initialize(invoker, event)
        @invoker = invoker
        @event = event
      end

      # Invoke a event handler chain by name
      #
      # @return [Boolean]
      def invoke(event_name, *args)
        @invoker.invoke(event_name, @event, *args)
      end
    end
  end
end
