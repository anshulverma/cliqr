# encoding: utf-8

require 'cliqr/dsl'

module Cliqr
  module CLI
    # The configuration setting to build a cli application with its own dsl
    class Config
      extend Cliqr::DSL

      UNSET = Object.new

      attr_accessor :basename

      attr_accessor :description

      attr_accessor :handler

      def initialize
        @basename = UNSET
        @description = UNSET
        @handler = UNSET
      end

      # Finalize config by adding default values for unset values.
      def finalize
        @basename = '' if @basename == UNSET
        @description = '' if @description == UNSET
        @handler = nil if @handler == UNSET
      end

      # Set value for a config option
      #
      # @param name
      #   name of the config parameter
      #
      # @param value
      #   value for the config parameter
      #
      # @return [String] value that was set for the parameter
      def set_config(name, value)
        public_send("#{name}=", value)
      end

      dsl do
        # dsl methods are handled dynamically by this method_missing block
        def method_missing(name, *args, &block)
          __getobj__.set_config name, args[0], &block
        end
      end
    end
  end
end
