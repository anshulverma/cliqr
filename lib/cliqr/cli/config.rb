# encoding: utf-8

require 'cliqr/dsl'

module Cliqr
  module CLI
    # The configuration setting to build a cli application with its own dsl
    class Config
      extend Cliqr::DSL

      def initialize
        @config = {}
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
        @config[name.to_sym] = value
      end

      # Finalize config by adding default values for unset values.
      #
      # @return [Hash]
      def finalize
        {
          basename: '',
          description: ''
        }.merge(@config)
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
