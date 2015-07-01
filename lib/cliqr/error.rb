# encoding: utf-8

module Cliqr
  module Error
    # Base error class that others error types extend from
    #
    # @api private
    class CliqrError < StandardError
      class << self
        # The error code based on the error condition
        #
        # @return [Integer]
        attr_accessor :error_code
      end

      @error_code = 100

      # Set up the error to wrap another error's trace
      #
      # @param [String] error_message A short error description
      # @param [Error] cause The cause of the error
      def initialize(error_message, cause = nil)
        super cause

        @error_message = error_message
        @cause = cause

        # Preserve the original exception's data if provided
        set_backtrace cause.backtrace if cause?
      end

      # Build a error message based on the cause of the error
      #
      # @return [String] Error message including the cause of the error
      def message
        if cause?
          "#{@error_message}\n\nCause: #{@cause.class} - #{@cause.message}\n"
        else
          @error_message
        end
      end

      # Get string representation of the error
      #
      # @return [String]
      def to_s
        message
      end

      private

      # Check if there was a nested cause for this error
      #
      # @return [Boolean] <tt>true</tt> if there was a valid cause for this error
      def cause?
        @cause && @cause.is_a?(Exception)
      end
    end

    # Raised when the config parameter is nil
    class ConfigNotFound < CliqrError; end

    # Signifies that the validation of the configuration settings failed
    class ValidationError < CliqrError; end

    # Encapsulates the error that gets thrown during a command execution
    class CommandRuntimeError < CliqrError
      @error_code = 101
    end

    # Raised if an argument does not conform to the option's type
    class IllegalArgumentError < CliqrError
      @error_code = 102
    end

    # Error to signify that a command's runner is not available
    class UnknownCommandRunnerException < CliqrError; end

    # Indicates to the user that the command line option is invalid
    class UnknownCommandOption < CliqrError; end

    # Raised to signal missing value for a option
    class OptionValueMissing < CliqrError; end

    # Indicates that a option has multiple values in the command line
    class MultipleOptionValues < CliqrError; end

    # Raised if more than one option is defined with same long or short name
    class DuplicateOptions < CliqrError; end

    # Raised if multiple actions are defined with same name at the same nesting level
    class DuplicateActions < CliqrError; end

    # Indicates that a unknown validator type is being used in a class
    class UnknownValidatorType < CliqrError; end

    # Indicates that a unknown action was invoked
    class UnknownActionError < CliqrError; end

    # Raised when a command is executed that is not supposed to run
    class IllegalCommandError < CliqrError; end
  end
end
