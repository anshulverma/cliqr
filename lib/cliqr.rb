# encoding: utf-8

require 'cliqr/interface'
require 'cliqr/version'
require 'cliqr/error'
require 'cliqr/config/command'
require 'cliqr/command/shell_prompt_builder'

# Top level namespace for the Cliqr gem
#
# @api public
module Cliqr
  class << self
    # Start building a cli interface
    #
    # @example
    #   Cliqr.interface do
    #     name 'my-command' # name of the command
    #     description 'command description in a few words' # long description
    #     handler MyCommandHandler # command's handler class
    #
    #     option
    #   end
    #
    # @return [Cliqr::Interface]
    #
    # @api public
    def interface(&block)
      config = Cliqr::Config::Command.build(&block)
      config.setup_defaults
      Cliqr::Interface.build(config)
    end

    # All cliqr commands should extend from this. Here is an example:
    #
    # @example
    #   class MyCommand < Cliqr.command
    #     def execute
    #       # execute the command
    #     end
    #   end
    #
    # @return [Cliqr::Command::BaseCommand]
    def command
      Command::BaseCommand
    end

    # A argument operator must extend from [Cliqr::Command::ArgumentOperator]
    #
    # @example
    #   class MyOperator < Cliqr.operator
    #     def operate(value)
    #       # return the operated value
    #     end
    #   end
    #
    # @return [Cliar::CLI::ArgumentOperator]
    def operator
      Command::ArgumentOperator
    end

    # A custom shell prompt builder must extend from this
    #
    # @example
    #   class MyCustomPrompt < Cliqr.shell_prompt
    #     def build(context)
    #       # build a prompt string
    #     end
    #   end
    #
    # @return [Cliqr::Command::ShellPromptBuilder]
    def shell_prompt
      Command::ShellPromptBuilder
    end

    # A custom shell banner builder must extend from this
    #
    # @example
    #   class MyCustomBanner < Cliqr.shell_banner
    #     def build(context)
    #       # build a banner string
    #     end
    #   end
    #
    # @return [Cliqr::Command::ShellBannerBuilder]
    def shell_banner
      Command::ShellBannerBuilder
    end

    # A custom event handler must extend from this
    #
    # @example
    #   class MyEventHandler < Cliqr.event_handler
    #     def handle(context, event)
    #       # handle event
    #     end
    #   end
    #
    # @return [Cliqr::Events::Handler]
    def event_handler
      Events::Handler
    end
  end
end
