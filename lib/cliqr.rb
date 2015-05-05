require 'cliqr/version'
require 'cliqr/cli'

# Top level namespace for the Cliqr gem
module Cliqr
  class << self
    # Invokes the CLI builder DSL
    # Alias for CLI#build
    #
    # @return [Cliqr::CLI]
    #
    # @api public
    def interface(&block)
      CLI.build(&block)
    end
  end
end
