# frozen_string_literal: true
module Cliqr
  module Events
    # Defines a event and its properties
    #
    # @api private
    class Event
      # Event's name
      #
      # @return [String]
      attr_reader :name

      # Command that was first invoked which resulted in this event
      #
      # @return [String]
      attr_reader :command

      # Time when the event was invoked
      #
      # @return [Time]
      attr_reader :timestamp

      # If this event was invoked from another event handler, this will ne non-nil
      #
      # @return [Cliqr::Events::Event]
      attr_reader :parent

      # Create a new event
      def initialize(name, command, parent)
        @name = name
        @command = command
        @parent = parent
        @timestamp = Time.now
        @propagate = true
      end

      # Check if this event has a parent event
      def parent?
        !parent.nil?
      end

      # Control event propagation
      def propagate?
        @propagate
      end

      # Unset propagation bit
      #
      # @return [Boolean]
      def stop_propagation
        @propagate = false
      end
    end
  end
end
