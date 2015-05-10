# encoding: utf-8

require 'cliqr/cli/validator'

module Cliqr
  module CLI
    # Builds usage information from [CLI::Config]
    class Builder
      # Start building a command line interface
      #
      # @param [Cliqr::CLI::Config] config
      #   the configuration options for the interface (validated using
      #   CLI::Validator)
      #
      # @return [Cliqr::CLI::Builder]
      def initialize(config)
        CLI::Validator.validate config
        @config = config
      end

      # Get usage information of this command line interface instance
      #
      # @return [String]
      #
      # @api public
      def usage
        template_file_path = File.expand_path('../../../../templates/usage.erb', __FILE__)
        template = ERB.new(File.new(template_file_path).read, nil, '%')
        template.result(@config.instance_eval { binding })
      end
    end
  end
end
