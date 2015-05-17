# encoding: utf-8

module Cliqr
  module Error
    # Base error class that others error types extend from
    #
    # @api private
    class CliqrError < StandardError
      # Set up the error to wrap another error's trace
      def initialize(error_message, cause = nil)
        super cause

        @error_message = error_message
        @cause = cause

        # Preserve the original exception's data if provided
        set_backtrace cause.backtrace if cause?
      end

      def message
        "#{@error_message}\n\nCause: #{@cause.class}" if cause?
        @error_message
      end

      private

      def cause?
        @cause && @cause.is_a?(Exception)
      end
    end

    # Raised when the config parameter is nil
    class ConfigNotFound < StandardError; end

    # Raised when basename is not defined
    class BasenameNotDefined < StandardError; end

    # Raised when a command handler is not defined
    class HandlerNotDefined < StandardError; end

    # Raised if command handler does not extend from Cliqr::CLI::Command
    class InvalidCommandHandler < StandardError; end

    # Encapsulates the error that gets thrown during a command execution
    class CommandRuntimeException < CliqrError; end

    # Error to signify that a command's runner is not available
    class UnknownCommandRunnerException < CliqrError; end

    # Raised if config's option array is nil
    class OptionsNotDefinedException < CliqrError; end

    # Indicates to the user that the command line option is invalid
    class InvalidCommandOption < CliqrError; end

    # Indicates to the user that the command line option is invalid
    class UnknownCommandOption < CliqrError; end
  end
end
