# encoding: utf-8

require 'cliqr/command/shell_prompt'

module Cliqr
  module Config
    # Config attributes for shell
    #
    # @api private
    class ShellConfig < Cliqr::Config::BaseConfig
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
                  { extend: Command::ShellPrompt },
                  { type_of: Proc },
                  { type_of: String }
                ]

      # Initialize a new config instance for an option with UNSET attribute values
      def initialize
        super

        @enabled = UNSET
        @prompt = UNSET
      end

      # Finalize shell's config by adding default values for unset values
      #
      # @return [Cliqr::Config::OptionConfig]
      def finalize
        case @enabled
        when Cliqr::Config::ENABLE_CONFIG
          @enabled = true
        when Cliqr::Config::DISABLE_CONFIG
          @enabled = false
        when UNSET
          @enabled = true
        end
        @prompt = Config.get_if_unset(@prompt, Command::ShellPrompt::DEFAULT_PROMPT)

        self
      end

      # Check if shell is enabled
      def enabled?
        @enabled
      end
    end
  end
end
