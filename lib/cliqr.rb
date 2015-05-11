# encoding: utf-8

require 'cliqr/version'
require 'cliqr/error'

require 'cliqr/cli/config'
require 'cliqr/cli/builder'
require 'cliqr/cli/command'

# Top level namespace for the Cliqr gem
#
# @api public
module Cliqr
  class << self
    # Start building a cli interface
    #
    # @example
    #   Cliqr.interface do
    #     basename 'my-command' # name of the command
    #     description 'command description in a few words' # long description
    #     handler MyCommandHandler # command's handler class
    #
    #     option
    #   end
    #
    # @return [Cliqr::CLI]
    #
    # @api public
    def interface(&block)
      config = CLI::Config.build(&block)
      CLI::Builder.new(config).build
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
    # @return [CLI::Command]
    def command
      CLI::Command
    end
  end
end
