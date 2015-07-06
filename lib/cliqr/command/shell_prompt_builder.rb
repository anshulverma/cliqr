# encoding: utf-8

module Cliqr
  module Command
    # Builds a shell prompt
    #
    # @api private
    class ShellPromptBuilder
      include Cliqr::Command::Color

      # Create a new shell prompt builder with optional command config
      def initialize(config = nil)
        super
        @count = 0
      end

      # Build a prompt for current command
      #
      # @return [String]
      def build(context)
        @count += 1
        "[#{cyan(context.command)}][#{@count}] #{bold('$')} "
      end
    end
  end
end
