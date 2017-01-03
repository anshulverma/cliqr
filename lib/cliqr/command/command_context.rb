# frozen_string_literal: true
require 'sawaal'

require 'cliqr/command/color'
require 'cliqr/command/argument_operator_context'
require 'cliqr/events/invoker'
require 'cliqr/command/output/standard_output_stream'
require 'cliqr/command/output/file_output_stream'

module Cliqr
  # Definition and builder for command context
  module Command
    # Manages things like arguments and input/output for a command
    #
    # @api private
    class CommandContext
      include Cliqr::Command::Color

      # Base command name
      #
      # @return [String]
      attr_accessor :base_command

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
      # @param [Cliqr::Config::Command] config The configuration settings
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
      def initialize(config, options, arguments, environment, executor, output_stream)
        super(config)

        @config = config
        @base_command = config.root.name
        @command = config.command
        @arguments = arguments
        @action_name = config.name
        @environment = environment
        @executor = executor
        @event_invoker = Events::Invoker.new(config, self)
        @output_stream = output_stream

        # make option map from array
        @options = Hash[*options.collect { |option| [option.name, option] }.flatten]
      end

      # List of parsed options
      #
      # @return [Array<Cliqr::Command::CommandOption>]
      def options
        @options.values
      end

      # Get an option by name
      #
      # @param [String] name Name of the option
      #
      # @return [Cliqr::Command::CommandOption] Instance of CommandOption for option
      def option(name)
        return @options[name] if option?(name)
        default(name)
      end

      # Check if an option with a specified name has been passed
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

      # Run the [Sawaal] selector on a set of options
      #
      # @return [Object] Selected key
      def ask(question, options)
        Sawaal.select(question, options)
      end

      # Invoke an event
      #
      # @return [Boolean] <tt>true</tt> if the event was handled by any event handler
      def invoke(event_name, *args)
        @event_invoker.invoke(event_name, nil, *args)
      end

      # Handle the case when a method is invoked to get an option value
      #
      # @return [Object] Option's value
      def method_missing(name, *_args, &_block)
        get_or_check_option(name)
      end

      # Get option value or check if it exists
      #
      # @return [Object]
      def get_or_check_option(name)
        option_name = name.to_s.chomp('?')
        existence_check = name.to_s.end_with?('?')
        existence_check ? option?(option_name) : option(option_name) \
          if @config.option?(option_name)
      end

      # Get default value for a option
      #
      # @return [Object]
      def default(name)
        option_config = @config.option(name)
        CommandOption.new(name, [option_config.default], option_config)
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
        CommandContext.new(@config.root, [], [], environment_type, @executor, @output_stream)
      end

      # Override the default puts implementation to enable output buffering
      #
      # @return [Nothing]
      def puts(message)
        @output_stream.write(message)
      end

      private :initialize, :default
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
        option_contexts = @parsed_input.options.map do |option_name, option_values|
          CommandOption.new(option_name, option_values, @config.option(option_name))
        end

        CommandContext.new @config,
                           option_contexts,
                           @parsed_input.arguments,
                           @options[:environment],
                           @executor,
                           build_output_stream(@options)
      end

      private

      # Build a output stream object to be used in the command handler
      #
      # @return [OutputStream]
      def build_output_stream(options)
        case options[:output]
        when :file
          Command::Output::FileOutputStream.new
        else
          Command::Output::StandardOutputStream.new
        end
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

      # Value array for the command line argument's option
      #
      # @return [Array]
      attr_accessor :values

      # Create a new command line option instance
      #
      # @param [String] name Name of the option
      # @param [Array] values Parsed values for this option
      # @param [Cliqr::Config::Option] option_config Option's config settings
      #
      # @return [Cliqr::Command::CommandContext] A new CommandOption object
      def initialize(name, values, option_config)
        @name = name
        @values = values.map { |value| run_value_operator(value, option_config.operator) }
      end

      # Get value for this option
      #
      # @return [Object] Joins in a CSV format if multiple
      def value
        return values.first if values.length == 1
        values.join(',')
      end

      # Get string representation for this option
      #
      # @return [String]
      def to_s
        value.to_s
      end

      private

      # Run the operator for a named attribute for option's values
      #
      # @return [Array]
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
