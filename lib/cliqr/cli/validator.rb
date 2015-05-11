# encoding: utf-8

require 'cliqr/error'

module Cliqr
  module CLI
    # Validator for the command line interface configuration
    #
    # @api private
    class Validator
      # Validates the config to make sure all the options are correctly set
      #
      # @param [Cliqr::CLI::Config] config Settings for building command line interface
      #
      # @return [Cliqr::CLI::Config] Validated config object
      def self.validate(config)
        fail Cliqr::Error::ConfigNotFound, 'config is nil' if config.nil?
        fail Cliqr::Error::BasenameNotDefined, 'basename is not defined' if config.basename.empty?

        fail Cliqr::Error::HandlerNotDefined, 'command handler not defined' if config.handler.nil?
        fail Cliqr::Error::InvalidCommandHandler,
             'command handler must extend from Cliqr::CLI::Command' unless config.handler < Command

        fail Cliqr::Error::OptionsNotDefinedException,
             'options cannot be nil' if config.options.nil?

        config
      end
    end
  end
end
