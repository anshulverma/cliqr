# encoding: utf-8

require 'cliqr/command/shell_prompt_builder'
require 'cliqr/command/shell_banner_builder'

module Cliqr
  module Config
    # Config attributes for shell
    #
    # @api private
    class Shell < Cliqr::Config::Named
      # Enable or disable the shell action
      #
      # @return [Symbol]
      attr_accessor :enabled
      validates :enabled,
                inclusion: [true, false]

      # Prompt for the shell
      #
      # @return [String]
      # @return [Proc]
      attr_accessor :prompt
      validates :prompt,
                one_of: [
                  { extend: Command::ShellPromptBuilder },
                  { type_of: Proc },
                  { type_of: String }
                ]

      # Banner that is displayed when shell starts
      #
      # @return [String]
      attr_accessor :banner
      validates :banner,
                one_of: [
                  { extend: Command::ShellBannerBuilder },
                  { type_of: Proc },
                  { type_of: String }
                ]

      # Initialize a new config instance for an option with UNSET attribute values
      def initialize
        super

        @enabled = UNSET
        @prompt = UNSET
        @banner = UNSET
      end

      # Finalize shell's config by adding default values for unset values
      #
      # @return [Cliqr::Config::Option]
      def finalize
        super

        case @enabled
        when Cliqr::Config::ENABLE_CONFIG
          @enabled = true
        when Cliqr::Config::DISABLE_CONFIG
          @enabled = false
        when UNSET
          @enabled = true
        end
        @prompt = Config.get_if_unset(@prompt, Cliqr::Command::ShellPromptBuilder::DEFAULT_PROMPT)
        @banner = Config.get_if_unset(@banner, Cliqr::Command::ShellBannerBuilder::DEFAULT_BANNER)

        # set default name for the shell action
        @name = 'shell' if @name.is_a?(String) && @name.empty?

        self
      end

      # Check if shell is enabled
      def enabled?
        @enabled
      end

      # Disable colors in shell
      #
      # @return [Cliqr::Command::Color]
      def disable_color
        @prompt.disable_color if @prompt.respond_to?(:disable_color)
      end
    end
  end
end
