# encoding: utf-8

require 'stringio'

module Cliqr
  module CLI
    # Factory class to get instance of CommandRunner based on input options
    #
    # @api private
    class CommandRunnerFactory
      # Get a instance of command runner based on options
      #
      # @param [Hash] options Used to build a command runner instance
      #
      # @return [Cliqr::CLI::StandardCommandRunner] If default output is require from command
      # @return [Cliqr::CLI::BufferedCommandRunner] If command's output needs to be buffered
      def self.get(**options)
        case options[:output]
        when :default
          StandardCommandRunner.new
        when :buffer
          BufferedCommandRunner.new
        else
          fail Cliqr::Error::UnknownCommandRunnerException,
               'cannot find a command runner for the given options'
        end
      end
    end

    # A standard implementation for command runner used for most commands
    #
    # @api private
    class StandardCommandRunner
      # simply execute the command handler
      #
      # @return [Integer] Exit status of the command
      def run
        yield
      end
    end

    # Used to buffer command output
    #
    # @api private
    class BufferedCommandRunner
      # Run the command handler but redirect stdout to a buffer
      #
      # @return [Hash] The hash contains :stdout, :stderr and :status of the command
      def run
        old_stdout = $stdout
        old_stderr = $stderr
        $stdout = old_stdout.is_a?(StringIO) ? old_stdout : StringIO.new('', 'w')
        $stderr = old_stderr.is_a?(StringIO) ? old_stderr : StringIO.new('', 'w')
        yield
        {
            :stdout => $stdout.string,
            :stderr => $stderr.string,
            :status => 0
        }
      ensure
        $stdout = old_stdout
        $stderr = old_stderr
      end
    end
  end
end
