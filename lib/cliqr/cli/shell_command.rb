# encoding: utf-8

require 'cliqr/cli/command'

module Cliqr
  # @api private
  module CLI
    # The default command executed to run a shell action
    #
    # @api private
    class ShellCommand < Cliqr::CLI::Command
      # Start a shell in the context of some other command
      #
      # @return [Integer] Exit code
      def execute(context)
        base_command = context.command[0...(context.command.rindex('shell'))].strip
        puts "Starting shell for command \"#{base_command}\""
        exit_code = ShellRunner.new(base_command, context).run
        puts "shell exited with code #{exit_code}"
        exit_code
      end
    end

    private

    # The runner for shell command
    class ShellRunner
      # Create the runner instance
      def initialize(base_command, context)
        @base_command = base_command
        @context = context
      end

      # Start shell
      #
      # @return [Integer] Exit code
      def run
        loop do
          command = prompt("#{@base_command} > ")
          execute(command) unless command == 'exit'
          break if command == 'exit'
        end
        0
      end

      private

      # Execute a shell command
      #
      # @return [Integer] Exit code of the command executed
      def execute(command)
        @context.forward "#{@base_command} #{command}"
      rescue StandardError => e
        puts e.message
      end

      # Show a prompt and ask for input
      #
      # @return [String]
      def prompt(prefix = '')
        print prefix
        $stdin.gets.chomp
      end
    end
  end
end
