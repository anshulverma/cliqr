# encoding: utf-8

require 'cliqr/cli/validator'
require 'cliqr/cli/interface'

module Cliqr
  module CLI
    # Builds usage information from [CLI::Config]
    #
    # @api private
    class Builder
      # Start building a command line interface
      #
      # @param [Cliqr::CLI::Config] config
      #   the configuration options for the interface (validated using
      #   CLI::Validator)
      #
      # @return [Cliqr::CLI::Builder]
      def initialize(config)
        @config = config
      end

      def build
        CLI::Validator.validate @config
        Interface.new(@config)
      end
    end
  end
end
