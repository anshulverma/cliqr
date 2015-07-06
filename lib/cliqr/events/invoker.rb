# encoding: utf-8

require 'cliqr/events/event'
require 'cliqr/events/event_context'

module Cliqr
  module Events
    # Invokes a event and associated event-chain by propagating the event
    #
    # @api private
    class Invoker
      # Create a new event invoker instance
      #
      # @param [Cliqr::Config::Action] config
      def initialize(config)
        @config = config
      end

      # Invoke a event in the context of the configuration set in this invoker
      #
      # @return [Boolean] <tt>true</tt> if the event was handled by an associated handler
      def invoke(event_name, parent_event, *args)
        handled = false
        current_config = @config
        event = build_event(event_name, parent_event)
        loop do
          if current_config.handle?(event_name)
            handle(event, current_config.event(event_name), *args)
            handled = true
            break unless event.propagate?
          end
          break if current_config.root?
          current_config = current_config.parent
        end
        handled
      end

      private

      # Build a event by name
      #
      # @return [Cliqr::Events::Event]
      def build_event(name, parent_event)
        Events::Event.new(name, @config.command, parent_event)
      end

      # Handle invocation of a event
      #
      # @return [Nothing]
      def handle(event, event_config, *args)
        context = Events::EventContext.new(self, event)
        context.instance_exec(event, *args, &wrap(event_config.handler, context))
      rescue StandardError => e
        raise Cliqr::Error::InvocationError.new("failed invocation for #{event.name}", e)
      end

      # Wrap the event invocation handler in a proc
      #
      # @return [Proc]
      def wrap(event_handler, context)
        return event_handler if event_handler.is_a?(Proc)
        handler = event_handler.new(context)
        proc do |*args|
          handler.handle(*args)
        end
      end
    end
  end
end
