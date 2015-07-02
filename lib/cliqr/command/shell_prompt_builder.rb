# encoding: utf-8

module Cliqr
  module Command
    # Builds a shell prompt
    #
    # @api private
    class ShellPromptBuilder
      # Default shell prompt
      DEFAULT_PROMPT = ShellPromptBuilder.new

      # Build a prompt for current command
      #
      # @return [String]
      def build(context)
        "#{context.command} > "
      end
    end
  end
end
