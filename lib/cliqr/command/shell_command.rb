# encoding: utf-8

module Cliqr
  # @api private
  module Command
    # The default command executed to run a shell action
    #
    # @api private
    class ShellCommand < Cliqr::Command::BaseCommand
      # Create a new shell command handler
      def initialize(shell_config)
        @shell_config = shell_config
      end

      # Start a shell in the context of some other command
      #
      # @return [Integer] Exit code
      def execute(context)
        fail(Cliqr::Error::IllegalCommandError,
             'Cannot run another shell within an already running shell') unless context.bash?

        base_command = context.command[0...(context.command.rindex('shell'))].strip
        puts "Starting shell for command \"#{base_command}\""

        exit_code = ShellRunner.new(base_command, context.root(:shell), build_prompt).run
        puts "shell exited with code #{exit_code}"
        exit_code
      end

      # Build a anonymous method to get prompt string
      #
      # @return [Proc]
      def build_prompt
        if @shell_config.prompt.is_a?(String)
          shell_prompt = @shell_config.prompt
          proc do
            shell_prompt
          end
        elsif @shell_config.prompt.is_a?(Proc)
          return @shell_config.prompt
        else
          shell_prompt = @shell_config.prompt.new
          proc do
            shell_prompt.prompt(self)
          end
        end
      end
    end

    private

    # The runner for shell command
    class ShellRunner
      # Create the runner instance
      def initialize(base_command, context, prompt)
        @base_command = base_command
        @context = context
        @prompt = prompt
      end

      # Start shell
      #
      # @return [Integer] Exit code
      def run
        loop do
          command = prompt
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
      def prompt
        print @context.instance_eval(&@prompt)
        $stdin.gets.chomp
      end
    end
  end
end
