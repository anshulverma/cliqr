# encoding: utf-8

require 'cliqr/error'

require 'cliqr/cli/router'
require 'cliqr/cli/command_runner_factory'

module Cliqr
  module CLI
    # A CLI interface instance which is the entry point for all CLI commands.
    #
    # @api public
    class Interface
      def initialize(config)
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
        result = template.result(@config.instance_eval { binding })

        # remove multiple newlines from the end of usage
        "#{result.strip}\n"
      end

      def execute(output: :default)
        handler = @config.handler.new
        begin
          runner = CommandRunnerFactory.get(output: output)
          runner.run do
            handler.execute
          end
        rescue StandardError => e
          raise Cliqr::Error::CommandRuntimeException.new "command '#{@config.basename}' failed", e
        end
      end
    end
  end
end
