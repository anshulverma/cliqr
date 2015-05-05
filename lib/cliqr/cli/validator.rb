require 'cliqr/error'

module Cliqr
  module CLI
    # Validator for the command line interface configuration
    class Validator
      def self.validate(config)
        fail Cliqr::Error::ConfigNotFound, 'config is nil' if config.nil?
      end
    end
  end
end
