# encoding: utf-8

require 'cliqr/config/dsl'
require 'cliqr/config/validation/verifiable'

module Cliqr
  # A extension for CLI module to group all config classes
  #
  # @api private
  module Config
    # The configuration setting to build a named configuration instance
    class Named < Cliqr::Config::Base
      # Name of the config instance
      #
      # @return [String]
      attr_accessor :name
      validates :name,
                non_empty_format: /^[a-zA-Z0-9_\-]+$/

      # Description for the config instance
      #
      # @return [String]
      attr_accessor :description

      # New config instance with all attributes set as UNSET
      def initialize
        @name = UNSET
        @description = UNSET
      end

      # Finalize config by adding default values for unset values
      #
      # @return [Cliqr::Config::Base]
      def finalize
        @name = Config.get_if_unset(@name, '')
        @description = Config.get_if_unset(@description, '')

        self
      end

      # Check if a option's description is defined
      #
      # @return [Boolean] <tt>true</tt> if options' description is not null neither empty
      def description?
        !(@description.nil? || @description.empty?)
      end
    end
  end
end
