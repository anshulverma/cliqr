# encoding: utf-8

require 'cliqr/events/handler'

module Cliqr
  module Config
    # The configuration setting which defines a event
    class Event < Cliqr::Config::Base
      # Name of the event
      #
      # @return [String]
      attr_accessor :name
      validates :name,
                non_empty_format: /^[a-zA-Z0-9_\-]+$/

      # Event handler
      #
      # @return [Cliqr::Events::Handler]
      attr_accessor :handler
      validates :handler,
                one_of: [
                  { type_of: Cliqr::Events::Handler },
                  { type_of: Proc }
                ]

      # New config instance with all attributes set as UNSET
      def initialize
        @name = UNSET
        @handler = UNSET
      end

      # Finalize config by adding default values for unset values
      #
      # @return [Cliqr::Config::Base]
      def finalize
        @name = Config.get_if_unset(@name, '')
        @handler = Config.get_if_unset(@handler, nil)

        self
      end
    end
  end
end
