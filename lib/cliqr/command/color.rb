# encoding: utf-8

module Cliqr
  module Command
    # Colors that can be used in a command to colorize strings
    #
    # @api private
    module Color
      @colors_enabled = true

      # Colorize a string with black color
      #
      # @return [String]
      def black(str)
        colorize(str, 30)
      end

      # Colorize a string with red color
      #
      # @return [String]
      def red(str)
        colorize(str, 31)
      end

      # Colorize a string with green color
      #
      # @return [String]
      def green(str)
        colorize(str, 32)
      end

      # Colorize a string with yellow color
      #
      # @return [String]
      def yellow(str)
        colorize(str, 33)
      end

      # Colorize a string with blue color
      #
      # @return [String]
      def blue(str)
        colorize(str, 34)
      end

      # Colorize a string with magenta color
      #
      # @return [String]
      def magenta(str)
        colorize(str, 35)
      end

      # Colorize a string with cyan color
      #
      # @return [String]
      def cyan(str)
        colorize(str, 36)
      end

      # Colorize a string with gray color
      #
      # @return [String]
      def gray(str)
        colorize(str, 37)
      end

      # Colorize a the background in black
      #
      # @return [String]
      def bg_black(str)
        colorize(str, 40)
      end

      # Colorize a the background in red
      #
      # @return [String]
      def bg_red(str)
        colorize(str, 41)
      end

      # Colorize a the background in green
      #
      # @return [String]
      def bg_green(str)
        colorize(str, 42)
      end

      # Colorize a the background in yellow
      #
      # @return [String]
      def bg_yellow(str)
        colorize(str, 43)
      end

      # Colorize a the background in blue
      #
      # @return [String]
      def bg_blue(str)
        colorize(str, 44)
      end

      # Colorize a the background in magenta
      #
      # @return [String]
      def bg_magenta(str)
        colorize(str, 45)
      end

      # Colorize a the background in cyan
      #
      # @return [String]
      def bg_cyan(str)
        colorize(str, 46)
      end

      # Colorize a the background in gray
      #
      # @return [String]
      def bg_gray(str)
        colorize(str, 47)
      end

      # Returns the bold representation
      #
      # @return [String]
      def bold(str)
        colorize(str, 1, 22)
      end

      # Reverses the color of a string and its background
      #
      # @return [String]
      def reverse_color(str)
        colorize(str, 7, 27)
      end

      private

      # Wrap a string in a specific color code
      #
      # @return [String]
      def colorize(str, color_code, end_tag = 0)
        "\033[#{color_code}m#{str}\033[#{end_tag}m"
      end
    end
  end
end
