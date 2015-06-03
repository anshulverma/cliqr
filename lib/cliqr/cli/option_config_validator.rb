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
        validate_option_name(config, parent_config)

        fail Cliqr::Error::InvalidOptionDefinition,
             "option \"#{config.name}\" has empty short name" \
              if !config.short.nil? && config.short.empty?

        validate_short_option(config, parent_config) if config.short?

        config
      end

      # Validates name for an option
      #
      # @param [Cliqr::CLI::OptionConfig] config Config for this particular option
      # @param [Cliqr::CLI::Config] parent_config Config of the parent config instance
      #
      # @return [Cliqr::CLI::OptionConfig] Validated OptionConfig instance
      def self.validate_option_name(config, parent_config)
        fail Cliqr::Error::DuplicateOptions,
             "multiple options with long name \"#{config.name}\"" \
             if parent_config.option?(config.name)

        config
      end

      # Validates short name for an option
      #
      # @param [Cliqr::CLI::OptionConfig] config Config for this particular option
      # @param [Cliqr::CLI::Config] parent_config Config of the parent config instance
      #
      # @return [Cliqr::CLI::OptionConfig] Validated OptionConfig instance
      def self.validate_short_option(config, parent_config)
        fail Cliqr::Error::DuplicateOptions,
             "multiple options with short name \"#{config.short}\"" \
              if parent_config.option?(config.short)

        fail Cliqr::Error::InvalidOptionDefinition,
             "short option name can not have more than one characters in \"#{config.name}\"" \
             if /^[a-z0-9A-Z]$/.match(config.short).nil?

        config
      end
    end
  end
end
