# encoding: utf-8

require 'cliqr/command/base_command'
require 'cliqr/config/action_config'
require 'cliqr/config/shell_config'

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
                child: true

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

        @shell = Config.get_if_unset(@shell, Cliqr::Util.build_shell_config(self))
        @version = Config.get_if_unset(@version, nil)

        self
      end

      # Set value for a config option
      #
      # @param [Symbol] name Name of the config parameter
      # @param [Object] value Value for the config parameter
      # @param [Proc] block Function which populates configuration for a sub-attribute
      #
      # @return [Object] attribute's value
      def set_config(name, value, &block)
        case name
        when :shell
          handle_shell(value, &block)
        else
          super
        end
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
        @shell.enabled?
      end

      # Check if version is enabled for this command
      #
      # @return [Boolean] <tt>true</tt> if help is enabled
      def version?
        !@version.nil?
      end

      private

      # Handle configuration for shell config
      #
      # @param [Symbol] setting Enabled shell if the setting is <tt>BaseConfig::ENABLE_CONFIG</tt>
      # @param [Proc] block Populate the shell's config in this block
      #
      # @return [Cliqr::Config::ShellConfig] Newly created shell config
      def handle_shell(setting, &block)
        @shell = ShellConfig.build(&block).tap do |shell_config|
          shell_config.enabled = setting
          shell_config.finalize
        end
      end

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
        add_action(Cliqr::Util.build_shell_action(self, @shell)) unless action?('shell')
      end
    end
  end
end
