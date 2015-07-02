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
        validate_environment(context)

        root_context = context.root(:shell)

        puts banner(root_context, build_proc(@shell_config.banner))

        exit_code = build_runner(context, root_context).run
        puts "shell exited with code #{exit_code}"
        exit_code
      end

      private

      # Build an instance of the ShellRunner
      #
      # @return [Cliqr::Command::ShellRunner]
      def build_runner(context, root_context)
        ShellRunner.new(context.command[0...(context.command.rindex('shell'))].strip,
                        root_context,
                        build_proc(@shell_config.prompt))
      end

      # Make sure a shell cannot be run inside an already running shell
      #
      # @return Nothing
      def validate_environment(context)
        fail(Cliqr::Error::IllegalCommandError,
             'Cannot run another shell within an already running shell') unless context.bash?
      end

      # Banner string for current command
      #
      # @return [String]
      def banner(context, block)
        context.instance_eval(&block)
      end

      # Build an anonymous method to wrap an attribute value
      #
      # @return [Proc]
      def build_proc(value)
        if value.is_a?(String)
          proc { value }
        elsif value.is_a?(Proc)
          return value
        else
          builder = value
          builder = value.new if value.is_a?(Class)
          proc do
            builder.build(self)
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
