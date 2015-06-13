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
    # @return [Hash] Parsed action config and hash of command line arguments
    def self.parse(config, args)
      tree_walker = ArgumentTreeWalker.new(config)
      action_config, parsed_input = tree_walker.walk(args)
      if parsed_input.option('help') && action_config.help?
        action_config = action_config.action(:help)
        parsed_input.remove_option('help')
      end
      [action_config, parsed_input]
    end
  end
end
