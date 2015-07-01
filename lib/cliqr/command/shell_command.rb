# encoding: utf-8

module Cliqr
  # @api private
  module Command
    # The default command executed to run a shell action
    #
    # @api private
    class ShellCommand < Cliqr::Command::BaseCommand
      # Start a shell in the context of some other command
      #
      # @return [Integer] Exit code
      def execute(context)
        fail(Cliqr::Error::IllegalCommandError,
             'Cannot run another shell within an already running shell') unless context.bash?

        base_command = context.command[0...(context.command.rindex('shell'))].strip
        puts "Starting shell for command \"#{base_command}\""

        exit_code = ShellRunner.new(base_command, context.root(:shell)).run
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
        return if command.empty?
        action_name = command.split(' ').first
        unless @context.action?(action_name)
          puts "unknown action \"#{action_name}\""
          return Cliqr::Executor::ExitCode.code(nil)
        end
        @context.forward("#{@base_command} #{command}", :environment => @context.environment)
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
