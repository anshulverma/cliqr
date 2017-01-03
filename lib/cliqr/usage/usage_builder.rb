# frozen_string_literal: true
require 'erb'
require 'cliqr/error'
require 'cliqr/usage/command_usage_context'

module Cliqr
  module Usage
    # Builds the usage information based on the configuration settings
    #
    # @api private
    class UsageBuilder
      TEMPLATES_PATH = "#{File.expand_path(File.dirname(__FILE__))}/templates"

      USAGE_TYPES = {
        cli: "#{TEMPLATES_PATH}/usage/cli.erb",
        shell: "#{TEMPLATES_PATH}/usage/shell.erb"
      }.freeze

      # Create a new usage builder
      def initialize(type)
        @type = type
        @template_file = USAGE_TYPES[type]
      end

      # Build the usage information
      #
      # @param [Cliqr::Config::Command] config Configuration of the command line interface
      #
      # @return [String]
      def build(config)
        usage_context = Usage::CommandUsageContext.new(@type, config)
        usage_context.instance_eval do
          def render(partial_name)
            TemplateRenderer.render("#{TEMPLATES_PATH}/partial/#{partial_name}.erb", self)
          end
        end

        # Add a extra newline at the end of usage text
        "#{TemplateRenderer.render(@template_file, usage_context)}\n"
      end
    end

    # Renders a template file based on configuration settings
    #
    # @api private
    class TemplateRenderer
      # Render a partial script
      #
      # @return [Nothing]
      def self.render(template_file_path, context)
        template_file_path = File.expand_path(template_file_path, __FILE__)
        template = ERB.new(File.new(template_file_path).read, nil, '%')
        result = template.result(context.instance_eval { binding })
        Cliqr::Util.trim_newlines(result)
      end
    end
  end
end
