# encoding: utf-8

require 'cliqr/command/base_command'
require 'cliqr/config/action_config'

module Cliqr
  module Config
    # Configuration setting for a command
    #
    # @api private
    class CommandConfig < Cliqr::Config::ActionConfig
      # Enable or disable the shell action for base config
      #
      # @return [Symbol] Either <tt>#ENABLE_CONFIG</tt> or <tt>#DISABLE_CONFIG</tt>
      attr_accessor :shell
      validates :shell,
                inclusion: [ENABLE_CONFIG, DISABLE_CONFIG]

      # Version tag for this configuration
      #
      # @return [Stirng]
      attr_accessor :version

      # New config instance with all attributes set as UNSET
      def initialize
        super

        @shell = UNSET
        @version = UNSET
      end

      # Finalize config by adding default values for unset values
      #
      # @return [Cliqr::Config::CommandConfig]
      def finalize
        super

        @shell = Config.get_if_unset(@shell, shell_default)
        @version = Config.get_if_unset(@version, nil)

        self
      end

      # Set up default attributes for this configuration
      #
      # @return [Cliqr::Config::CommandConfig] Update config
      def setup_defaults
        super

        add_shell
        add_version
      end

      # Check if this configuration has shell action enabled
      #
      # @return [Boolean]
      def shell?
        @shell == ENABLE_CONFIG
      end

      # Check if version is enabled for this command
      #
      # @return [Boolean] <tt>true</tt> if help is enabled
      def version?
        !@version.nil?
      end

      private

      # Add version command and option to this config
      #
      # @return [Cliqr::Config::CommandConfig] Updated config
      def add_version
        return self unless version?
        add_action(Cliqr::Util.build_version_action(self)) unless action?('version')
        add_option(Cliqr::Util.build_version_option(self)) unless option?('version')
      end

      # Add shell command
      #
      # @return [Cliqr::Config::CommandConfig] Updated config
      def add_shell
        return self unless shell?
        add_action(Cliqr::Util.build_shell_action(self)) unless action?('shell')
      end

      # Get default setting for shell attribute
      #
      # @return [Symbol]
      def shell_default
        root? && actions? ? ENABLE_CONFIG : DISABLE_CONFIG
      end
    end
  end
end
