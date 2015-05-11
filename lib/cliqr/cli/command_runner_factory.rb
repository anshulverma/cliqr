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
      # @param [Hash] options used to build a command runner instance
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

    # a standard implementation for command runner used for most commands
    class StandardCommandRunner
      # simply execute the command handler
      def run
        yield
      end
    end

    # used to buffer command output
    class BufferedCommandRunner
      # run the command handler but redirect stdout to a buffer
      def run
        old_stdout = $stdout
        $stdout = StringIO.new('', 'w')
        yield
        $stdout.string
      ensure
        $stdout = old_stdout
      end
    end
  end
end
