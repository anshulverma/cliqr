# encoding: utf-8

require 'cliqr/dsl'
require 'cliqr/util'
require 'cliqr/config_validation/verifiable'
require 'cliqr/cli/command'
require 'cliqr/cli/argument_operator'

module Cliqr
  # A extension for CLI module to group all config classes
  module CLI
    # A value to initialize configuration attributes with
    UNSET = Object.new

    # Configuration option to enable arguments for a command (default)
    ENABLE_CONFIG = :enable

    # Configuration option to disable arguments for a command
    DISABLE_CONFIG = :disable

    # Option type for regular options
    ANY_ARGUMENT_TYPE = :any

    # Option type for numeric arguments
    NUMERIC_ARGUMENT_TYPE = :numeric

    # Option type for boolean arguments
    BOOLEAN_ARGUMENT_TYPE = :boolean

    # Default values based on argument type
    ARGUMENT_DEFAULTS = {
        NUMERIC_ARGUMENT_TYPE => 0,
        BOOLEAN_ARGUMENT_TYPE => false,
        ANY_ARGUMENT_TYPE => nil
    }

    # The configuration setting to build a cli application with its own dsl
    #
    # @api private
    class Config
      extend Cliqr::DSL
      include Cliqr::ConfigValidation

      # Name of the command
      #
      # @return [String]
      attr_accessor :name
      validates :name,
                non_empty_format: /^[a-zA-Z0-9_\-]+$/

      # Description for the base command
      #
      # @return [String]
      attr_accessor :description

      # Command handler for the base command
      #
      # @return [Class<Cliqr::CLI::Command>]
      attr_accessor :handler
      validates :handler,
                one_of: {
                    extend: Cliqr::CLI::Command,
                    type_of: Proc
                }

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
      # @return [Cliqr::CLI::Config]
      attr_accessor :parent

      # Root config
      #
      # @return [Cliqr::CLI::Config]
      attr_accessor :root

      # New config instance with all attributes set as UNSET
      def initialize
        @name = UNSET
        @description = UNSET
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
      # @return [Cliqr::CLI::Config]
      def finalize
        @name = '' if @name == UNSET
        @description = '' if @description == UNSET
        @handler = Util.ensure_instance(@handler == UNSET ? nil : @handler)
        @arguments = ENABLE_CONFIG if @arguments == UNSET
        @help = ENABLE_CONFIG if @help == UNSET
        @root = self

        self
      end

      # Set up default attributes for this configuration
      #
      # @return [Cliqr::CLI::Config] Update config
      def setup_defaults
        add_help if help?
        @actions.each(&:setup_defaults)
      end

      # Set value for a config option
      #
      # @param [Symbol] name Name of the config parameter
      # @param [Object] value Value for the config parameter
      # @param [Proc] block Function which populates configuration for a sub-attribute
      #
      # @return [Object] if setting a attribute's value
      # @return [Cliqr::CLI::OptionConfig] if adding a new option
      # @return [Cliqr::CLI::Config] if adding a new action
      def set_config(name, value, &block)
        case name
        when :option
          handle_option value, &block # value is the long name for the option
        when :action
          handle_action value, &block # value is action's name
        else
          value = block if block_given?
          handle_config name, value
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

      # Get action config by name
      #
      # @param [String] name Name of the action
      #
      # @return [Cliqr::CLI::Config] Configuration of the action
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

      # Set value for config option without evaluating a block
      #
      # @param [Symbol] name Name of the config option
      # @param [Object] value Value for the config option
      #
      # @return [Object] Value that was assigned to attribute
      def handle_config(name, value)
        public_send("#{name}=", value)
        value
      end

      # Handle configuration for a new option
      #
      # @param [Symbol] name Long name of the option
      # @param [Proc] block Populate the option's config in this funciton block
      #
      # @return [Cliqr::CLI::OptionConfig] Newly created option's config
      def handle_option(name, &block)
        option_config = OptionConfig.build(&block)
        option_config.name = name
        add_option(option_config)
      end

      # Add a new option for the command
      #
      # @return [Cliqr::CLI::OptionConfig] Newly added option's config
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
      # @return [Cliqr::CLI::Config] The newly configured action
      def handle_action(name, &block)
        action_config = Config.build(&block)
        action_config.name = name
        add_action(action_config)
      end

      # Add a new action
      #
      # @return [Cliqr::CLI::Config] The newly added action
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
      # @param [Cliqr::CLI::OptionConfig] option_config Config for this particular option
      #
      # @return [Cliqr::CLI::OptionConfig] Validated OptionConfig instance
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
      # @param [Cliqr::CLI::Config] action_config Config for this particular action
      #
      # @return [Cliqr::CLI::Config] Validated action's Config instance
      def validate_action_name(action_config)
        fail Cliqr::Error::DuplicateActions,
             "multiple actions named \"#{action_config.name}\"" \
             if action?(action_config.name)

        action_config
      end

      # Add help command and option to this config
      #
      # @return [Cliqr::CLI::Config] Updated config
      def add_help
        add_action(Cliqr::Util.build_help_action(self)) unless action?('help')
        add_option(Cliqr::Util.build_help_option(self)) unless option?('help')
      end
    end

    # Config attributes for a command's option
    #
    # @api private
    class OptionConfig
      extend Cliqr::DSL
      include Cliqr::ConfigValidation

      # Long option name
      #
      # @return [String]
      attr_accessor :name
      validates :name,
                non_empty: true,
                format: /^[a-zA-Z0-9_\-]*$/

      # Optional short name for the option
      #
      # @return [String]
      attr_accessor :short
      validates :short,
                non_empty_nil_ok_format: /^[a-z0-9A-Z]$/

      # A description string for the option
      #
      # @return [String]
      attr_accessor :description

      # Optional field that restricts values of this option to a certain type
      #
      # @return [Symbol] Type of the option
      attr_accessor :type
      validates :type,
                inclusion: [:any, NUMERIC_ARGUMENT_TYPE, BOOLEAN_ARGUMENT_TYPE]

      # Operation to be applied to the option value after validation
      #
      # @return [Class<Cliqr::CLI::ArgumentOperator>]
      attr_accessor :operator
      validates :operator,
                one_of: {
                    extend: Cliqr::CLI::ArgumentOperator,
                    type_of: Proc
                }

      # Default value for this option
      #
      # @return [Object]
      attr_accessor :default

      # Set value for command option's attribute
      #
      # @param [Symbol] name Name of the attribute
      # @param [Object] value Value for the attribute
      # @param [Proc] block A anonymous block to initialize the config value
      #
      # @return [Object] Value that was set for the attribute
      def set_config(name, value, &block)
        value = block if block_given?
        handle_option_config name, value
      end

      # Initialize a new config instance for an option with UNSET attribute values
      def initialize
        @name = UNSET
        @short = UNSET
        @description = UNSET
        @type = UNSET
        @operator = UNSET
        @default = UNSET
      end

      # Finalize option's config by adding default values for unset values
      #
      # @return [Cliqr::CLI::OptionConfig]
      def finalize
        @name = get_if_unset(@name, nil)
        @short = get_if_unset(@short, nil)
        @description = get_if_unset(@description, nil)
        @type = get_if_unset(@type, ANY_ARGUMENT_TYPE)
        @operator = Util.ensure_instance(get_if_unset(@operator, ArgumentOperator.for_type(@type)))
        @default = get_if_unset(@default, ARGUMENT_DEFAULTS[@type])

        self
      end

      # Check if a option's short name is defined
      #
      # @return [Boolean] <tt>true</tt> if options' short name is not null neither empty
      def short?
        !(@short.nil? || @short.empty?)
      end

      # Check if a option's description is defined
      #
      # @return [Boolean] <tt>true</tt> if options' description is not null neither empty
      def description?
        !(@description.nil? || @description.empty?)
      end

      # Check if a option's type is defined
      #
      # @return [Boolean] <tt>true</tt> if options' type is not nil and not equal to <tt>:any</tt>
      def type?
        !@type.nil? && @type != :any
      end

      # Check if a option is of boolean type
      #
      # @return [Boolean] <tt>true</tt> is the option is of type <tt>:boolean</tt>
      def boolean?
        @type == :boolean
      end

      # Check if a default value setting is defined
      #
      # @return [Boolean]
      def default?
        !@default.nil?
      end

      private

      # Set value for config option without evaluating a block
      #
      # @param [Symbol] name Name of the config option
      # @param [Object] value Value for the config option
      #
      # @return [Object]
      def handle_option_config(name, value)
        public_send("#{name}=", value)
        value
      end

      # Get the passed param value if current attribute is unset
      #
      # @return [Object]
      def get_if_unset(attribute_value, default_value)
        attribute_value == UNSET ? default_value : attribute_value
      end
    end
  end
end
