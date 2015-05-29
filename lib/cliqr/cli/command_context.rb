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
      # @param [Hash] parsed_args A hash of parsed command line arguments
      #
      # @return [Cliqr::CLI::CommandContext]
      def self.build(parsed_args)
        CommandContextBuilder.new(parsed_args).build
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

      private :initialize
    end

    private

    # Builder for creating a instance of CommandContext from parsed cli arguments
    #
    # @api private
    class CommandContextBuilder
      # Initialize builder for CommandContext
      #
      # @param [Hash] parsed_args Parsed and validated command line arguments
      #
      # @return [Cliqr::CLI::CommandContextBuilder]
      def initialize(parsed_args)
        @parsed_args = parsed_args
      end

      # Build a new instance of CommandContext
      #
      # @return [Cliqr::CLI::CommandContext] A newly created CommandContext instance
      def build
        CommandContext.new @parsed_args[:command],
                           @parsed_args[:options].map { |args| CommandOption.new(args) }
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
      # @param [Hash] args Arguments for creating a command line option
      #
      # @return [Cliqr::CLI::CommandContext] A new CommandOption object
      def initialize(args)
        @name = args[:name]
        @value = args[:value]
      end
    end
  end
end
