# encoding: utf-8

module Cliqr
  module CLI
    # Base class for all commands to extend from
    #
    # @api private
    class Command
      # Execute the command
      #
      # @return [Integer] Exit status of the command execution
      def execute(_context)
        0
      end
    end
  end
end
