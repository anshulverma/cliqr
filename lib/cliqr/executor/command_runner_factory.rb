# rubocop:disable Style/FrozenStringLiteralComment

require 'stringio'

module Cliqr
  module Executor
    # Factory class to get instance of CommandRunner based on input options
    #
    # @api private
    class CommandRunnerFactory
      # Get a instance of command runner based on options
      #
      # @param [Hash] options Used to build a command runner instance
      #
      # @return [Cliqr::Executor::StandardCommandRunner] If default output is require from command
      # @return [Cliqr::Executor::BufferedCommandRunner] If command's output needs to be buffered
      def self.get(**options)
        case options[:output]
        when :buffer
          BufferedCommandRunner.new
        else
          StandardCommandRunner.new
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
          stdout: $stdout.string,
          stderr: $stderr.string,
          status: 0
        }
      ensure
        $stdout = old_stdout
        $stderr = old_stderr
      end
    end
  end
end
