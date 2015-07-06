# encoding: utf-8

module Cliqr
  module Events
    # The context in which event handlers are invoked
    #
    # @api private
    class EventContext
      # Create a new event context to execute events
      def initialize(invoker, context, event)
        @invoker = invoker
        @context = context
        @event = event
      end

      # Invoke a event handler chain by name
      #
      # @return [Boolean]
      def invoke(event_name, *args)
        @invoker.invoke(event_name, @event, *args)
      end

      # Handle the case when a method is invoked to get an option value
      #
      # @return [Object] Option's value
      def method_missing(name, *_args, &_block)
        @context.get_or_check_option(name)
      end
    end
  end
end
