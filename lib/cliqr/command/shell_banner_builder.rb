# frozen_string_literal: true
module Cliqr
  module Command
    # Used to build a banner string for shell
    #
    # @api private
    class ShellBannerBuilder
      # Build the banner based on current context
      #
      # @return [String]
      def build(context)
        "Starting shell for command \"#{context.command}\""
      end
    end
  end
end
