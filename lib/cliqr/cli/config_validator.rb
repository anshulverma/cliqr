# encoding: utf-8

require 'cliqr/error'

module Cliqr
  module CLI
    # Validator for the command line interface configuration
    #
    # @api private
    class ConfigValidator
      # Validates the config to make sure all the options are correctly set
      #
      # @param [Cliqr::CLI::Config] config Settings for building command line interface
      #
      # @return [Cliqr::CLI::Config] Validated config object
      def self.validate(config)
        fail Cliqr::Error::ConfigNotFound, 'a valid config should be defined' if config.nil?
        fail Cliqr::Error::BasenameNotDefined, 'basename not defined' if config.basename.empty?

        fail Cliqr::Error::HandlerNotDefined,
             "handler not defined for command \"#{config.basename}\"" if config.handler.nil?

        unless config.handler < Command
          fail Cliqr::Error::InvalidCommandHandler,
               "handler for command \"#{config.basename}\" should extend from [Cliqr::CLI::Command]"
        end

        fail Cliqr::Error::OptionsNotDefinedException,
             "option array is nil for command \"#{config.basename}\"" if config.options.nil?

        config
      end
    end
  end
end
