# encoding: utf-8

module Cliqr
  # Definition and builder for command context
  module CLI
    # Manages things like arguments and input/output for a command
    #
    # @api private
    class CommandContext
      # Command name
      #
      # @return [String]
      attr_accessor :command

      # Build a instance of command context based on the parsed set of arguments
      #
      # @param [Cliqr::Parser::ParsedInput] parsed_input Parsed input object
      #
      # @return [Cliqr::CLI::CommandContext]
      def self.build(parsed_input)
        CommandContextBuilder.new(parsed_input).build
      end

      # Initialize the command context (called by the CommandContextBuilder)
      #
      # @return [Cliqr::CLI::CommandContext]
      def initialize(command, options)
        @command = command
        # make option map from array
        @options = Hash[*options.collect { |option| [option.name, option] }.flatten]
      end

      # List of parsed options
      #
      # @return [Array<Cliqr::CLI::CommandOption>]
      def options
        @options.values
      end

      # Get a option by name
      #
      # @param [String] name Name of the option
      #
      # @return [Cliqr::CLI::CommandOption] Instance of CommandOption for option
      def option(name)
        @options[name]
      end

      # Check if a option with a specified name has been passed
      #
      # @param [String] name Name of the option
      #
      # @return [Boolean] <tt>true</tt> if the option has a argument value
      def option?(name)
        @options.key?(name)
      end

      private :initialize
    end

    private

    # Builder for creating a instance of CommandContext from parsed cli arguments
    #
    # @api private
    class CommandContextBuilder
      # Initialize builder for CommandContext
      #
      # @param [Cliqr::Parser::ParsedInput] parsed_input Parsed and validated command line arguments
      #
      # @return [Cliqr::CLI::CommandContextBuilder]
      def initialize(parsed_input)
        @parsed_input = parsed_input
      end

      # Build a new instance of CommandContext
      #
      # @return [Cliqr::CLI::CommandContext] A newly created CommandContext instance
      def build
        CommandContext.new @parsed_input.command,
                           @parsed_input.options.map { |option| CommandOption.new(option) }
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
      #
      # @return [Cliqr::CLI::CommandContext] A new CommandOption object
      def initialize(option)
        @value = option.pop
        @name = option.pop
      end
    end
  end
end
