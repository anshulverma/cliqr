# encoding: utf-8

require 'cliqr/error'
require 'cliqr/cli/executor'
require 'cliqr/cli/usage_builder'

module Cliqr
  # Definition and builder for command line interface
  module CLI
    # Exit code hash map
    EXIT_CODE = {
        success: 0,
        'Cliqr::Error::CommandRuntimeError'.to_sym => 1,
        'Cliqr::Error::IllegalArgumentError'.to_sym => 2
    }

    # A CLI interface instance which is the entry point for all CLI commands.
    #
    # @api private
    class Interface
      # Command line interface configuration
      #
      # @return [Cliqr::CLI::Config]
      attr_accessor :config

      # Create a new interface instance with a config
      #
      # @param [Cliqr::CLI::Config] config Config used to create this interface
      def initialize(config)
        @config = config
        @executor = Executor.new(config)
      end

      # Get usage information of this command line interface instance
      #
      # @return [String] Defines usage of this interface
      def usage
        UsageBuilder.build(config)
      end

      # Execute a command
      #
      # @param [Array<String>] args Arguments that will be used to execute the command
      # @param [Hash] options Options for command execution
      #
      # @return [Integer] Exit code of the command execution
      def execute(args = [], **options)
        begin
          execute_internal(args, options)
          Cliqr::CLI::EXIT_CODE[:success]
        rescue Cliqr::Error::CliqrError => e
          puts e.message
          Cliqr::CLI::EXIT_CODE[e.class.to_s.to_sym]
        end

      end

      # Executes a command without handling error conditions
      #
      # @return [Integer] Exit code
      def execute_internal(args = [], **options)
        options = {
            :output => :default,
            :environment => :bash
        }.merge(options)
        @executor.execute(args, options)
      end

      # Invoke the builder method for [Cliqr::CLI::Interface]
      #
      # @param [Cliqr::CLI::Config] config Instance of the command line config
      #
      # @return [Cliqr::CLI::Interface]
      def self.build(config)
        InterfaceBuilder.new(config).build
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
      #
      # @throws [Cliqr::Error::ConfigNotFound] if a config is <tt>nil</tt>
      # @throws [Cliqr::Error::ValidationError] if the validation for config fails
      def build
        fail Cliqr::Error::ConfigNotFound, 'a valid config should be defined' if @config.nil?
        fail Cliqr::Error::ValidationError, \
             "invalid Cliqr interface configuration - [#{@config.errors}]" unless @config.valid?

        Interface.new(@config)
      end
    end
  end
end
