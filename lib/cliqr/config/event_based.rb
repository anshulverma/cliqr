# encoding: utf-8

require 'cliqr/config/event'

module Cliqr
  module Config
    # The configuration that enabled events for another configuration
    class EventBased < Cliqr::Config::Base
      # Events to listen for
      #
      # @return [Hash] A hash of <tt>String => Cliqr::Config::Event</tt>
      attr_accessor :events
      validates :events,
                hash: true

      # New instance of event based config
      def initialize
        @events = {}
      end

      # Add a event
      #
      # @param [Symbol] name Name of the attribute
      # @param [String] event_name Event's name
      # @param [Array] args Event handler
      # @param [Proc] block Event handler function
      #
      # @return [Cliqr::Config::Event] Newly added event
      def set_config(name, event_name, *args, &block)
        case name
        when :on
          # if defined, args[0] will be the custom event handler class
          handle_event(event_name, args[0], &block)
        else
          super
        end
      end

      # Check if a event can be handled in this context
      def handle?(name)
        @events.key?(name.to_s)
      end

      # Get a event handler config by name
      #
      # @return [Cliqr::Config::Event]
      def event(name)
        @events[name.to_s]
      end

      private

      # Handle the case when a event is added to the config
      #
      # @return [Cliqr::Events::Event]
      def handle_event(event_name, event_class, &event_block)
        fail Cliqr::Error::ValidationError, 'only one of event_class or event_block are allowed' \
          if !event_class.nil? && block_given?

        event_handler = event_class
        event_handler = event_block if event_class.nil?
        event = build_event(event_name, event_handler)
        @events[event.name.to_s] = event
      end

      # Builds a event invocation handler wrapper
      #
      # @return [Cliqr::Events::Event]
      def build_event(event_name, event_handler)
        Cliqr::Config::Event.new.tap do |event|
          event.name = event_name if event_name.is_a?(String) || event_name.is_a?(Symbol)
          event.handler = event_handler
          event.finalize
        end
      end
    end
  end
end
