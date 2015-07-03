# encoding: utf-8

require 'cliqr/command/base_command'
require 'cliqr/config/action'
require 'cliqr/config/shell'

module Cliqr
  module Config
    # Configuration setting for a command
    #
    # @api private
    class Command < Cliqr::Config::Action
      # Configuration for the shell for this command
      #
      # @return [Cliqr::Command::ShellConfig]
      attr_accessor :shell
      validates :shell,
                child: true

      # Version tag for this configuration
      #
      # @return [Stirng]
      attr_accessor :version

      # Enable or disable colors in a command handler (default enabled)
      #
      # @return [Symbol]
      attr_accessor :color
      validates :color,
                inclusion: [Cliqr::Config::ENABLE_CONFIG, Cliqr::Config::DISABLE_CONFIG]

      # New config instance with all attributes set as UNSET
      def initialize
        super

        @shell = UNSET
        @version = UNSET
        @color = UNSET
      end

      # Finalize config by adding default values for unset values
      #
      # @return [Cliqr::Config::Command]
      def finalize
        super

        @color = Config.get_if_unset(@color, Cliqr::Config::ENABLE_CONFIG)
        @shell = Config.get_if_unset(@shell, Cliqr::Util.build_shell_config(self))
        @version = Config.get_if_unset(@version, nil)

        # disable colors in shell if colors are disabled here
        @shell.disable_color unless color?

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
      # @return [Cliqr::Config::Command] Update config
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

      # The root of command config is itself
      #
      # @return [Cliqr::Config::Command]
      def root
        self
      end

      # Check if colors are enabled for this setting
      def color?
        @color == Cliqr::Config::ENABLE_CONFIG
      end

      private

      # Handle configuration for shell config
      #
      # @param [Symbol] setting Enabled shell if the setting is <tt>BaseConfig::ENABLE_CONFIG</tt>
      # @param [Proc] block Populate the shell's config in this block
      #
      # @return [Cliqr::Config::Shell] Newly created shell config
      def handle_shell(setting, &block)
        @shell = Shell.build(&block).tap do |shell_config|
          unless setting.nil?
            shell_config.enabled = setting
            shell_config.finalize
          end
        end
      end

      # Add version command and option to this config
      #
      # @return [Cliqr::Config::Command] Updated config
      def add_version
        return self unless version?
        add_action(Cliqr::Util.build_version_action(self)) unless action?('version')
        add_option(Cliqr::Util.build_version_option(self)) unless option?('version')
      end

      # Add shell command
      #
      # @return [Cliqr::Config::Command] Updated config
      def add_shell
        return self unless shell?
        add_action(Cliqr::Util.build_shell_action(self, @shell)) unless action?('shell')
      end
    end
  end
end
