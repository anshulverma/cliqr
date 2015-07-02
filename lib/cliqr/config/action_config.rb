# encoding: utf-8

require 'cliqr/util'
require 'cliqr/command/base_command'
require 'cliqr/config/base_config'
require 'cliqr/config/option_config'

module Cliqr
  module Config
    # Configuration setting for an action
    #
    # @api private
    class ActionConfig < Cliqr::Config::NamedConfig
      # Command handler for the base command
      #
      # @return [Class<Cliqr::Command::BaseCommand>]
      attr_accessor :handler
      validates :handler,
                one_of: [
                  { extend: Cliqr::Command::BaseCommand },
                  { type_of: Proc }
                ]

      #  Dictates whether this command can take arbitrary arguments (optional)
      #
      # @return [Symbol] Either <tt>#ENABLE_CONFIG</tt> or <tt>#DISABLE_CONFIG</tt>
      attr_accessor :arguments
      validates :arguments,
                inclusion: [ENABLE_CONFIG, DISABLE_CONFIG]

      # Array of options applied to the base command
      #
      # @return [Array<OptionConfig>]
      attr_accessor :options
      validates :options,
                collection: true

      # Array of children action configs for this action
      #
      # @return [Array<Cliqr::CLI::Config>]
      attr_accessor :actions
      validates :actions,
                collection: true

      # Enable or disable help command and option
      #
      # @return [Symbol] Either <tt>#ENABLE_CONFIG</tt> or <tt>#DISABLE_CONFIG</tt>
      attr_accessor :help
      validates :help,
                inclusion: [ENABLE_CONFIG, DISABLE_CONFIG]

      # Parent configuration
      #
      # @return [Cliqr::Config::CommandConfig]
      attr_accessor :parent

      # Root config
      #
      # @return [Cliqr::Config::CommandConfig]
      attr_accessor :root

      # New config instance with all attributes set as UNSET
      def initialize
        super

        @handler = UNSET
        @arguments = UNSET
        @help = UNSET

        @options = []
        @option_index = {}

        @actions = []
        @action_index = {}
      end

      # Finalize config by adding default values for unset values
      #
      # @return [Cliqr::Config::CommandConfig]
      def finalize
        super

        @handler = Util.ensure_instance(Config.get_if_unset(@handler, nil))
        @arguments = Config.get_if_unset(@arguments, ENABLE_CONFIG)
        @help = Config.get_if_unset(@help, ENABLE_CONFIG)
        @root = self

        self
      end

      # Set up default attributes for this configuration
      #
      # @return [Cliqr::Config::CommandConfig] Update config
      def setup_defaults
        add_help
        @handler = Cliqr::Util.forward_to_help_handler if @handler.nil? && help? && actions?
        @actions.each(&:setup_defaults)
      end

      # Set value for a config option
      #
      # @param [Symbol] name Name of the config parameter
      # @param [Object] value Value for the config parameter
      # @param [Proc] block Function which populates configuration for a sub-attribute
      #
      # @return [Object] if setting a attribute's value
      # @return [Cliqr::Config::BaseConfig] if adding a new action or option
      def set_config(name, value, &block)
        case name
        when :option
          handle_option(value, &block) # value is the long name for the option
        when :action
          handle_action(value, &block) # value is action's name
        else
          super
        end
      end

      # Check if options are set
      #
      # @return [Boolean] <tt>true</tt> if the CLI config's options have been set
      def options?
        @options != UNSET
      end

      # Check if particular option is set
      #
      # @param [String] name Name of the option to check
      #
      # @return [Boolean] <tt>true</tt> if the CLI config's option is set
      def option?(name)
        @option_index.key?(name.to_s)
      end

      # Get value of a option
      #
      # @param [String] name Name of the option
      #
      # @return [String] value for the option
      def option(name)
        @option_index[name.to_s]
      end

      # Check if particular action exists
      #
      # @param [String] name Name of the action to check
      #
      # @return [Boolean] <tt>true</tt> if the action exists in the configuration
      def action?(name)
        return false if name.nil?
        @action_index.key?(name.to_sym)
      end

      # Check if this config has sub actions
      #
      # @return [Boolean]
      def actions?
        !@actions.empty?
      end

      # Get action config by name
      #
      # @param [String] name Name of the action
      #
      # @return [Cliqr::Config::ActionConfig] Configuration of the action
      def action(name)
        @action_index[name.to_sym]
      end

      # Check if arguments are enabled for this configuration
      #
      # @return [Boolean] <tt>true</tt> if arguments are enabled
      def arguments?
        @arguments == ENABLE_CONFIG
      end

      # Get name of the command along with the action upto this config
      #
      # @return [String] Serialized command name
      def command
        return name unless parent?
        "#{@parent.command} #{name}"
      end

      # Check if this config has a parent config
      #
      # @return [Boolean] <tt>true</tt> if there exists a parent action for this action
      def parent?
        !@parent.nil?
      end

      # Check if help is enabled for this command
      #
      # @return [Boolean] <tt>true</tt> if help is enabled
      def help?
        @help == ENABLE_CONFIG
      end

      private

      # Handle configuration for a new option
      #
      # @param [Symbol] name Long name of the option
      # @param [Proc] block Populate the option's config in this function block
      #
      # @return [Cliqr::Config::OptionConfig] Newly created option's config
      def handle_option(name, &block)
        option_config = OptionConfig.build(&block)
        option_config.name = name
        add_option(option_config)
      end

      # Add a new option for the command
      #
      # @return [Cliqr::Config::OptionConfig] Newly added option's config
      def add_option(option_config)
        validate_option_name(option_config)

        @options.push(option_config)
        @option_index[option_config.name.to_s] = option_config
        @option_index[option_config.short.to_s] = option_config if option_config.short?

        option_config
      end

      # Handle configuration for a new action
      #
      # @param [String] name Name of the action
      # @param [Function] block The block which configures this action
      #
      # @return [Cliqr::Config::ActionConfig] The newly configured action
      def handle_action(name, &block)
        action_config = ActionConfig.build(&block)
        action_config.name = name
        add_action(action_config)
      end

      # Add a new action
      #
      # @return [Cliqr::Config::ActionConfig] The newly added action
      def add_action(action_config)
        action_config.parent = self
        action_config.root = root

        validate_action_name(action_config)

        @actions.push(action_config)
        @action_index[action_config.name.to_sym] = action_config \
          unless action_config.name.nil?

        action_config
      end

      # Make sure that the option's name is unique
      #
      # @param [Cliqr::Config::OptionConfig] option_config Config for this particular option
      #
      # @return [Cliqr::Config::OptionConfig] Validated OptionConfig instance
      def validate_option_name(option_config)
        fail Cliqr::Error::DuplicateOptions,
             "multiple options with long name \"#{option_config.name}\"" \
             if option?(option_config.name)

        fail Cliqr::Error::DuplicateOptions,
             "multiple options with short name \"#{option_config.short}\"" \
              if option?(option_config.short)

        option_config
      end

      # Make sure that the action's name is unique
      #
      # @param [Cliqr::Config::ActionConfig] action_config Config for this particular action
      #
      # @return [Cliqr::Config::ActionConfig] Validated action's Config instance
      def validate_action_name(action_config)
        fail Cliqr::Error::DuplicateActions,
             "multiple actions named \"#{action_config.name}\"" \
             if action?(action_config.name)

        action_config
      end

      # Add help command and option to this config
      #
      # @return [Cliqr::Config::BaseConfig] Updated config
      def add_help
        return self unless help?
        add_action(Cliqr::Util.build_help_action(self)) unless action?('help')
        add_option(Cliqr::Util.build_help_option(self)) unless option?('help')
      end
    end
  end
end
