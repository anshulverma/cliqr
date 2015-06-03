# encoding: utf-8

require 'cliqr/error'

module Cliqr
  module CLI
    # Validator for validating option configuration in a CLI interface config
    #
    # @api private
    class OptionConfigValidator
      # Validate a command line interface's config for an option
      #
      # @param [Cliqr::CLI::OptionConfig] config Config for this particular option
      # @param [Cliqr::CLI::Config] parent_config Config of the parent config instance
      #
      # @return [Cliqr::CLI::OptionConfig] Validated OptionConfig instance
      def self.validate(config, parent_config)
        fail Cliqr::Error::DuplicateOptions,
             "multiple options with long name \"#{config.name}\"" \
             if parent_config.option?(config.name)

        fail Cliqr::Error::DuplicateOptions,
             "multiple options with short name \"#{config.short}\"" \
              if parent_config.option?(config.short)

        config
      end
    end
  end
end
