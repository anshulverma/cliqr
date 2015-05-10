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

      def initialize
        @basename = UNSET
        @description = UNSET
      end

      # Finalize config by adding default values for unset values.
      def finalize
        @basename = '' if @basename == UNSET
        @description = '' if @description == UNSET
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

      # dsl methods
      dsl do
        # Set basename for the command line interface
        #
        # @param [String] basename
        #   name of the top level command
        def basename(basename)
          set_config :basename, basename
        end

        # Set short description for the base command
        #
        # @param [String] description
        #   short description for the base command
        def description(description)
          set_config :description, description
        end
      end
    end
  end
end
