# encoding: utf-8

module Cliqr
  module CLI
    # Utiity class to parse input argument list
    #
    # @api private
    class ArgumentParser
      # Create a ArgumentParser
      #
      # @param [Cliqr::CLI::Config] config Command line configuration
      #
      # @return [Cliqr::CLI::ArgumentParser]
      def initialize(config)
        @config = config
      end

      # Parse command line arguments based on [Cliqr::CLI::Config]
      #
      # @param [Array<String>] args An array of arguments from command line
      #
      # @return [Hash] Parsed hash of command linet arguments
      def parse(args)
        if args.empty?
          return {
              :command => @config.basename,
              :options => []
          }
        end

        {
            :command => @config.basename,
            :options => [
              {
                :name => args[0].to_sym,
                :value => args[1].to_s
              }
            ]
        }
      end
    end
  end
end
