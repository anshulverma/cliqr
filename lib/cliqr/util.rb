# encoding: utf-8

require 'cliqr/command/shell_command'

module Cliqr
  # Utility methods
  #
  # @api private
  class Util
    # Ensure that a variable is a instance object not a class type
    #
    # @return [Object]
    def self.ensure_instance(obj)
      return obj.new if obj.class == Class
      obj
    end

    # Build a help action for a parent config
    #
    # @return [Cliqr::CLI::Config] New action config
    def self.build_help_action(config)
      cli = Cliqr.interface do
        name 'help'
        description "The help action for command \"#{config.command}\" which provides details " \
                    'and usage information on how to use the command.'
        handler Util.help_action_handler(config)
        help :disable if config.help?
        shell :disable
      end
      cli.config
    end

    # Build a help option for a parent config
    #
    # @return [Cliqr::CLI::OptionConfig] New option config
    def self.build_help_option(config)
      Cliqr::Config::OptionConfig.new.tap do |option_config|
        option_config.name = 'help'
        option_config.short = 'h'
        option_config.description = "Get helpful information for action \"#{config.command}\" " \
                                    'along with its usage information.'
        option_config.type = Cliqr::Config::BOOLEAN_ARGUMENT_TYPE
        option_config.operator = Cliqr::Command::ArgumentOperator::DEFAULT_ARGUMENT_OPERATOR
        option_config.finalize
      end
    end

    # Build a version action for a parent config
    #
    # @return [Cliqr::CLI::Config] New action config
    def self.build_version_action(config)
      cli = Cliqr.interface do
        name 'version'
        description "Get version information for command \"#{config.command}\"."
        handler do
          puts config.version
        end
        shell :disable
      end
      cli.config
    end

    # Build a version option for a parent config
    #
    # @return [Cliqr::CLI::OptionConfig] New option config
    def self.build_version_option(config)
      Cliqr::Config::OptionConfig.new.tap do |option_config|
        option_config.name = 'version'
        option_config.short = 'v'
        option_config.description = "Get version information for command \"#{config.command}\"."
        option_config.type = Cliqr::Config::BOOLEAN_ARGUMENT_TYPE
        option_config.operator = Cliqr::Command::ArgumentOperator::DEFAULT_ARGUMENT_OPERATOR
        option_config.finalize
      end
    end

    # Action handler for help action
    #
    # @return [Proc]
    def self.help_action_handler(config)
      proc do
        fail Cliqr::Error::IllegalArgumentError,
             "too many arguments for \"#{command}\" command" if arguments.length > 1
        action_config = arguments.length == 0 ? config : config.action(arguments.first)
        puts Cliqr::Usage::UsageBuilder.new(environment).build(action_config)
      end
    end

    # Build a shell action for a parent config
    #
    # @return [Cliqr::CLI::Config] New action config
    def self.build_shell_action(config)
      cli = Cliqr.interface do
        name 'shell'
        description "Execute a shell in the context of \"#{config.command}\" command."
        handler Cliqr::Command::ShellCommand
        shell :disable
      end
      cli.config
    end

    # Sanitize raw command line arguments
    #
    # @return [Array<String>]
    def self.sanitize_args(args, config = nil)
      sanitized = []
      if args.is_a?(Array)
        args.each { |arg| sanitized.concat(sanitize_args(arg)) }
      elsif args.is_a?(String)
        sanitized = args.split(' ')
      end
      remove_base_command(sanitized, config)
    end

    # Remove base command form sanitized list of arguments
    #
    # @return [Array<String>]
    def self.remove_base_command(sanitized, config)
      if !config.nil? && sanitized[0] == config.root.name.to_s
        sanitized.drop(1)
      else
        sanitized
      end
    end

    # Get handler that forwards command to the help action
    #
    # @return [Proc]
    def self.forward_to_help_handler
      proc do
        fail Cliqr::Error::IllegalArgumentError,
             'no arguments allowed for default help action' unless arguments.empty?
        forward "#{command} help"
      end
    end

    # Remove newlines from the end of a string
    #
    # @return [String]
    def self.trim_newlines(str)
      index = str.length - 1
      count = 0
      while str[index] == "\n" && index >= 0
        count += 1
        index -= 1
      end
      str[0...-count]
    end
  end
end
