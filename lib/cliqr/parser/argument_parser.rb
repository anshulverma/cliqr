# encoding: utf-8

require 'cliqr/parser/argument_tree_walker'

module Cliqr
  # A set of utility methods and classes used to parse the command line arguments
  #
  # @api private
  module Parser
    # Parse command line arguments based on [Cliqr::CLI::Config]
    #
    # @param [Cliqr::CLI::Config] config Command line configuration
    # @param [Array<String>] args An array of arguments from command line
    #
    # @return [Hash] Parsed hash of command linet arguments
    def self.parse(config, args)
      tree_walker = ArgumentTreeWalker.new(config)
      tree_walker.walk(args)
    end
  end
end
