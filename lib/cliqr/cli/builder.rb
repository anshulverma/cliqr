# encoding: utf-8

require 'cliqr/cli/validator'

module Cliqr
  module CLI
    # Builds usage information from [CLI::Config]
    class Builder
      # Start building a command line interface
      #
      # @param [Hash] config
      #   the configuration options for the interface (validated using
      #   CLI::Validator)
      #
      # @return [Cliqr::CLI::Builder]
      def initialize(config)
        CLI::Validator.validate config
        @basename = config[:basename]
        @description = config[:description]
      end

      # Get usage information of this command line interface instance
      #
      # @return [String]
      #
      # @api public
      def usage
        <<-EOS
#{@basename} -- #{@description}

USAGE:
    #{@basename}
EOS
      end
    end
  end
end
