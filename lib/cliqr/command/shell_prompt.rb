# encoding: utf-8

module Cliqr
  module Command
    # Builds a shell prompt
    #
    # @api private
    class ShellPrompt
      # Default shell prompt
      DEFAULT_PROMPT = ShellPrompt.new

      # Return the command in the current context
      #
      # @return [String]
      def prompt(_context)
      end
    end
  end
end
