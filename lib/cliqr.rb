# encoding: utf-8

require 'cliqr/interface'
require 'cliqr/version'
require 'cliqr/error'
require 'cliqr/config/command_config'

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
    # @return [Cliqr::CLI::Interface]
    #
    # @api public
    def interface(&block)
      config = Cliqr::Config::CommandConfig.build(&block)
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
    # @return [Cliqr::CLI::Command]
    def command
      Command::BaseCommand
    end

    # A argument operator must extend from [Cliqr::CLI::ArgumentOperator]
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
  end
end
