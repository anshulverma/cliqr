# encoding: utf-8

module Cliqr
  module Command
    # Builds a shell prompt
    #
    # @api private
    class ShellPromptBuilder
      include Cliqr::Command::Color

      # Default shell prompt
      DEFAULT_PROMPT = ShellPromptBuilder.new

      # Create a new shell prompt builder with optional command config
      def initialize(config = nil)
        super
      end

      # Build a prompt for current command
      #
      # @return [String]
      def build(context)
        "#{cyan(context.command)} #{bold('>')} "
      end
    end
  end
end
