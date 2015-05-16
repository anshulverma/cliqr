# encoding: utf-8

module Cliqr
  module CLI
    # Utiity class to validate input to a command
    #
    # @api private
    class ArgumentValidator
      # Validate parsed command line arguments
      #
      # @param [Hash] args Parsed argument hash
      #
      # @return [Hash] Validated argument hash
      def validate(args)
        args
      end
    end
  end
end
