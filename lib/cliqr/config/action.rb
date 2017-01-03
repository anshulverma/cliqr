# frozen_string_literal: true
require 'cliqr/util'
require 'cliqr/command/base_command'
require 'cliqr/config/base'
require 'cliqr/config/option_based'

module Cliqr
  module Config
    # Configuration setting for an action
    #
    # @api private
    class Action < Cliqr::Config::OptionBased
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

      # New config instance with all attributes set as UNSET
      def initialize
        super

        @handler = UNSET
        @arguments = UNSET
        @help = UNSET

        @actions = []
        @action_index = {}
      end

      # Finalize config by adding default values for unset values
      #
      # @return [Cliqr::Config::Action]
      def finalize
        super

        @handler = Util.ensure_instance(Config.get_if_unset(@handler, nil))
        @arguments = Config.get_if_unset(@arguments, ENABLE_CONFIG)
        @help = Config.get_if_unset(@help, ENABLE_CONFIG)

        self
      end

      # Set up default attributes for this configuration
      #
      # @return [Cliqr::Config::Command] Update config
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
      # @return [Cliqr::Config::Base] if adding a new action or option
      def set_config(name, value, *args, &block)
        case name
        when :action
          handle_action(value, &block) # value is action's name
        else
          super
        end
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
      # @return [Cliqr::Config::Action] Configuration of the action
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

      # The root of action config is itself unless otherwise configured
      #
      # @return [Cliqr::Config::Action]
      def root
        self
      end

      # Check if this action is the root
      def root?
        self == root
      end

      private

      # Handle configuration for a new action
      #
      # @param [String] name Name of the action
      # @param [Function] block The block which configures this action
      #
      # @return [Cliqr::Config::Action] The newly configured action
      def handle_action(name, &block)
        action_config = Action.build(&block)
        action_config.name = name
        add_action(action_config)
      end

      # Add a new action
      #
      # @return [Cliqr::Config::Action] The newly added action
      def add_action(action_config)
        parent = self
        action_config.parent = parent
        action_config.instance_eval do
          def root
            parent.root
          end
        end

        validate_action_name(action_config)

        @actions.push(action_config)
        @action_index[action_config.name.to_sym] = action_config \
          unless action_config.name.nil?

        action_config
      end

      # Make sure that the action's name is unique
      #
      # @param [Cliqr::Config::Action] action_config Config for this particular action
      #
      # @return [Cliqr::Config::Action] Validated action's Config instance
      def validate_action_name(action_config)
        if action?(action_config.name)
          raise Cliqr::Error::DuplicateActions,
                "multiple actions named \"#{action_config.name}\""
        end

        action_config
      end

      # Add help command and option to this config
      #
      # @return [Cliqr::Config::Base] Updated config
      def add_help
        return self unless help?
        add_action(Cliqr::Util.build_help_action(self)) unless action?('help')
        add_option(Cliqr::Util.build_help_option(self)) unless option?('help')
      end
    end
  end
end
