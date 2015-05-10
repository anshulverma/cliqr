# encoding: utf-8

require 'cliqr/error'

module Cliqr
  module CLI
    # Validator for the command line interface configuration
    class Validator
      def self.validate(config)
        fail Cliqr::Error::ConfigNotFound, 'config is nil' if config.nil?
        fail Cliqr::Error::BasenameNotDefined, 'basename is not defined' if config.basename.empty?
      end
    end
  end
end
