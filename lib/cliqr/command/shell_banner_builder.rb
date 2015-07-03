# encoding: utf-8

module Cliqr
  module Command
    # Used to build a banner string for shell
    #
    # @api private
    class ShellBannerBuilder
      # Default shell banner
      DEFAULT_BANNER = ShellBannerBuilder.new

      # Build the banner based on current context
      #
      # @return [String]
      def build(context)
        "Starting shell for command \"#{context.command}\""
      end
    end
  end
end