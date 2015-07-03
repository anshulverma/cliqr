# encoding: utf-8

require 'cliqr/command/color'
require 'cliqr/command/argument_operator_context'

module Cliqr
  # Definition and builder for command context
  module Command
    # Manages things like arguments and input/output for a command
    #
    # @api private
    class CommandContext
      include Cliqr::Command::Color

      # Command name
      #
      # @return [String]
      attr_accessor :command

      # Command arguments
      #
      # @return [Array<String>] List of arguments
      attr_accessor :arguments

      # Name of the current action
      #
      # @return [String]
      attr_accessor :action_name

      # Environment type
      #
      # @return [String]
      attr_reader :environment

      # Build a instance of command context based on the parsed set of arguments
      #
      # @param [Cliqr::Config::CommandConfig] config The configuration settings
      # @param [Cliqr::Parser::ParsedInput] parsed_input Parsed input object
      # @param [Hash] options Options for command execution
      # @param [Proc] executor Executes forwarded commands
      #
      # @return [Cliqr::Command::CommandContext]
      def self.build(config, parsed_input, options, &executor)
        CommandContextBuilder.new(config, parsed_input, options, executor).build
      end

      # Initialize the command context (called by the CommandContextBuilder)
      #
      # @return [Cliqr::Command::CommandContext]
      def initialize(config, options, arguments, environment, executor)
        @config = config
        @command = config.command
        @arguments = arguments
        @action_name = config.name
        @context = self
        @environment = environment
        @executor = executor

        # make option map from array
        @options = Hash[*options.collect { |option| [option.name, option] }.flatten]

        # check and disable colors if needed
        check_color_setting
      end

      # List of parsed options
      #
      # @return [Array<Cliqr::Command::CommandOption>]
      def options
        @options.values
      end

      # Get a option by name
      #
      # @param [String] name Name of the option
      #
      # @return [Cliqr::Command::CommandOption] Instance of CommandOption for option
      def option(name)
        return @options[name] if option?(name)
        default(name)
      end

      # Check if a option with a specified name has been passed
      #
      # @param [String] name Name of the option
      #
      # @return [Boolean] <tt>true</tt> if the option has a argument value
      def option?(name)
        @options.key?(name)
      end

      # Check whether a action is valid in current context
      #
      # @param [String] name Name of the action to check
      #
      # @return [Boolean] <tt>true</tt> if this context has the requested action
      def action?(name)
        @config.action?(name)
      end

      # Check if the current context if for a action
      def action_type?
        @config.parent?
      end

      # Forward a command to the executor
      #
      # @return [Integer] Exit code
      def forward(args, options = {})
        @executor.call(args, options)
      end

      # Handle the case when a method is invoked to get an option value
      #
      # @return [Object] Option's value
      def method_missing(name, *_args, &_block)
        option_name = name.to_s.chomp('?')
        existence_check = name.to_s.end_with?('?')
        existence_check ? option?(option_name) : option(option_name).value \
          if @config.option?(option_name)
      end

      # Get default value for a option
      #
      # @return [Object]
      def default(name)
        option_config = @config.option(name)
        CommandOption.new([name, option_config.default], option_config)
      end

      # Check if running in a bash environment
      #
      # @return [Boolean]
      def bash?
        @environment == :cli
      end

      # Transform this context to the root context
      #
      # @param [Symbol] environment_type Optional environment type
      #
      # @return [Cliqr::Command::CommandContext]
      def root(environment_type = nil)
        environment_type = @environment if environment_type.nil?
        CommandContext.new(@config.root, [], [], environment_type, @executor)
      end

      # Check if color is disabled
      #
      # @return [Cliqr::Command::CommandContext]
      def check_color_setting
        return self if @config.root.color?

        instance_eval do
          def colorize(str, *_args)
            str
          end
        end
      end

      private :initialize, :default, :check_color_setting
    end

    private

    # Builder for creating a instance of CommandContext from parsed cli arguments
    #
    # @api private
    class CommandContextBuilder
      # Initialize builder for CommandContext
      #
      # @param [Cliqr::Command::Config] config The configuration settings
      # @param [Cliqr::Parser::ParsedInput] parsed_input Parsed and validated command line arguments
      # @param [Hash] options Options for command execution
      # @param [Proc] executor Executes forwarded commands
      #
      # @return [Cliqr::Command::CommandContextBuilder]
      def initialize(config, parsed_input, options, executor)
        @config = config
        @parsed_input = parsed_input
        @options = options
        @executor = executor
      end

      # Build a new instance of CommandContext
      #
      # @return [Cliqr::Command::CommandContext] A newly created CommandContext instance
      def build
        option_contexts = @parsed_input.options.map do |option|
          CommandOption.new(option, @config.option(option.first))
        end

        CommandContext.new @config,
                           option_contexts,
                           @parsed_input.arguments,
                           @options[:environment],
                           @executor
      end
    end

    # A holder class for a command line argument's name and value
    #
    # @api private
    class CommandOption
      # Name of a command line argument option
      #
      # @return [String]
      attr_accessor :name

      # Value for the command line argument's option
      #
      # @return [Object]
      attr_accessor :value

      # Create a new command line option instance
      #
      # @param [Array] option Parsed arguments for creating a command line option
      # @param [Cliqr::Config::OptionConfig] option_config Option's config settings
      #
      # @return [Cliqr::Command::CommandContext] A new CommandOption object
      def initialize(option, option_config)
        @value = run_value_operator(option.pop, option_config.operator)
        @name = option.pop
      end

      private

      # Run the operator for a named attribute for a value
      #
      # @return [Nothing]
      def run_value_operator(value, operator)
        if operator.is_a?(Proc)
          Command::ArgumentOperatorContext.new(value).instance_eval(&operator)
        else
          operator.operate(value)
        end
      end
    end
  end
end
