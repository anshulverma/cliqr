# frozen_string_literal: true
module Cliqr
  module Command
    # Base class for all commands to extend from
    #
    # @api private
    class BaseCommand
      # Execute the command
      #
      # @return [Integer] Exit status of the command execution
      def execute(_context)
        0
      end
    end
  end
end
