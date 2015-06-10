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
    ENABLE_ARGUMENTS = :enable

    # Configuration option to disable arguments for a command
    DISABLE_ARGUMENTS = :disable

    # Option type for numeric arguments
    NUMERIC_ARGUMENT_TYPE = :numeric

    # Option type for boolean arguments
    BOOLEAN_ARGUMENT_TYPE = :boolean

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
      # @return [Symbol] Either <tt>#ENABLE_ARGUMENTS</tt> or <tt>#DISABLE_ARGUMENTS</tt>
      attr_accessor :arguments
      validates :arguments,
                inclusion: [ENABLE_ARGUMENTS, DISABLE_ARGUMENTS]

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

      # Parent configuration
      #
      # @return [Cliqr::CLI::Config]
      attr_writer :parent

      # New config instance with all attributes set as UNSET
      def initialize
        @name = UNSET
        @description = UNSET
        @handler = UNSET
        @arguments = UNSET

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
        @arguments = ENABLE_ARGUMENTS if @arguments == UNSET

        self
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
        @option_index.key?(name)
      end

      # Get value of a option
      #
      # @param [String] name Name of the option
      #
      # @return [String] value for the option
      def option(name)
        @option_index[name]
      end

      # Check if particular action exists
      #
      # @param [String] name Name of the action to check
      #
      # @return [Boolean] <tt>true</tt> if the action exists in the configuration
      def action?(name)
        @action_index.key?(name)
      end

      # Get action config by name
      #
      # @param [String] name Name of the action
      #
      # @return [Cliqr::CLI::Config] Configuration of the action
      def action(name)
        @action_index[name]
      end

      # Check if arguments are enabled for this configuration
      #
      # @return [Boolean] <tt>true</tt> if arguments are enabled
      def arguments?
        @arguments == ENABLE_ARGUMENTS
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

      # Add a new option for the command
      #
      # @param [Symbol] name Long name of the option
      # @param [Proc] block Populate the option's config in this funciton block
      #
      # @return [Cliqr::CLI::OptionConfig] Newly created option's config
      def handle_option(name, &block)
        option_config = OptionConfig.build(&block)
        option_config.name = name

        validate_option_name(option_config)

        @options.push(option_config)
        @option_index[option_config.name] = option_config
        @option_index[option_config.short] = option_config if option_config.short?

        option_config
      end

      # Add a new action to the list of actions
      #
      # @param [String] name Name of the action
      # @param [Function] block The block which configures this action
      #
      # @return [Cliqr::CLI::Config] The newly configured action
      def handle_action(name, &block)
        action_config = Config.build(&block)
        action_config.name = name
        action_config.parent = self

        validate_action_name(action_config)

        @actions.push(action_config)
        @action_index[action_config.name] = action_config

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
      end

      # Finalize option's config by adding default values for unset values
      #
      # @return [Cliqr::CLI::OptionConfig]
      def finalize
        @name = nil if @name == UNSET
        @short = nil if @short == UNSET
        @description = nil if @description == UNSET
        @type = :any if @type == UNSET
        @operator = Util.ensure_instance(
          @operator == UNSET ? ArgumentOperator.for_type(@type) : @operator)

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
    end
  end
end
