# encoding: utf-8

require 'cliqr/version'
require 'cliqr/error'

require 'cliqr/cli/config'
require 'cliqr/cli/builder'
require 'cliqr/cli/command'

# Top level namespace for the Cliqr gem
module Cliqr
  class << self
    # Invokes the CLI::Config builder DSL to prepare config for command line
    # application. Then uses that config to build a instance of type Cliqr::CLI
    #
    # @return [Cliqr::CLI]
    #
    # @api public
    def interface(&block)
      config = CLI::Config.build(&block)
      CLI::Builder.new(config).build
    end

    def command
      CLI::Command
    end
  end
end
