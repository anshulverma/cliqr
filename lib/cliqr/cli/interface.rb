# encoding: utf-8

require 'cliqr/error'

require 'cliqr/cli/router'
require 'cliqr/cli/config_validator'
require 'cliqr/cli/argument_parser'
require 'cliqr/cli/argument_validator'
require 'cliqr/cli/command_context'

module Cliqr
  # Definition and builder for command line interface
  module CLI
    # A CLI interface instance which is the entry point for all CLI commands.
    #
    # @api private
    class Interface
      # Create a new interface instance with a config
      #
      # @param [Cliqr::CLI::Config] config Config used to create this interface
      def initialize(config)
        @config = config

        @parser = ArgumentParser.new(config)
        @validator = ArgumentValidator.new
        @router = Router.new(config)
      end

      # Get usage information of this command line interface instance
      #
      # @return [String] Defines usage of this interface
      def usage
        template_file_path = File.expand_path('../../../../templates/usage.erb', __FILE__)
        template = ERB.new(File.new(template_file_path).read, nil, '%')
        result = template.result(@config.instance_eval { binding })

        # remove multiple newlines from the end of usage
        "#{result.strip}\n"
      end

      # Execute a command
      #
      # @param [Array<String>] args Arguments that will be used to execute the command
      # @param [Hash] options Options for command execution
      #
      # @return [Integer] Exit code of the command execution
      def execute(args, **options)
        options = {
            :output => :default
        }.merge(options)

        begin
          command_context = CommandContext.build(parse(args))
          @router.handle command_context, **options
        rescue StandardError => e
          raise Cliqr::Error::CommandRuntimeException.new("command '#{@config.basename}' failed", e)
        end
      end

      # Invoke the builder method for [Cliqr::CLI::Interface]
      #
      # @param [Cliqr::CLI::Config] config Instance of the command line config
      #
      # @return [Cliqr::CLI::Interface]
      def self.build(config)
        InterfaceBuilder.new(config).build
      end

      private

      # Invoke the command line argument parser
      #
      # @return [Hash] Parsed hash of command line arguments
      def parse(args)
        parsed_args = @parser.parse args
        @validator.validate(parsed_args)
        parsed_args
      end
    end

    private

    # Builder for [Cliqr::CLI::Interface]
    #
    # @api private
    class InterfaceBuilder
      # Start building a command line interface
      #
      # @param [Cliqr::CLI::Config] config the configuration options for the
      # interface (validated using CLI::Validator)
      #
      # @return [Cliqr::CLI::ConfigBuilder]
      def initialize(config)
        @config = config
      end

      # Validate and build a cli interface based on the configuration options
      #
      # @return [Cliqr::CLI::Interface]
      def build
        CLI::ConfigValidator.validate @config
        Interface.new(@config)
      end
    end
  end
end
