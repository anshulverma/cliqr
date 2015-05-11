# encoding: utf-8

module Cliqr
  module Error
    # Base error class that others error types extend from
    class CliqrError < StandardError
      def initialize(error_message, e = nil)
        super e

        # Preserve the original exception's data if provided
        return unless e && e.is_a?(Exception)

        set_backtrace e.backtrace
        message.prepend "#{error_message}\n\nCause:\n#{e.class}: "
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
  end
end
