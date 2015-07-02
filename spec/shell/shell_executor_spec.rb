# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'
require 'fixtures/test_shell_prompt'

describe Cliqr::Command::ShellCommand do
  it 'can execute help in command shell' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      description 'this is a test command'

      action :foo do
        description 'the foo action'
      end

      action :bar do
        description 'bar command'

        action :baz
      end
    end

    with_input(%w(help -h)) do
      result = cli.execute_internal %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > help.
my-command -- this is a test command

Available actions:
[ Type "help [action-name]" to get more information about that action ]

    foo -- the foo action
    bar -- bar command
    help -- The help action for command "my-command" which provides details and usage information on how to use the command.
my-command > -h.
unknown action "-h"
my-command > exit.
shell exited with code 0
      EOS
    end

    with_input(['help bar']) do
      result = cli.execute_internal %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > help bar.
my-command bar -- bar command

Available actions:
[ Type "help [action-name]" to get more information about that action ]

    baz
    help -- The help action for command "my-command bar" which provides details and usage information on how to use the command.
my-command > exit.
shell exited with code 0
      EOS
    end
  end

  it 'can execute a sub action from shell' do
    cli = Cliqr.interface do
      name 'my-command'
      handler do
        puts 'base command executed'
      end

      action :foo do
        handler do
          puts 'foo executed'
        end

        action :bar do
          handler do
            puts 'bar executed'
            puts "option: #{opt}" if opt?
          end

          option :opt
        end
      end
    end

    with_input(['', 'my-command', 'foo', 'foo bar', 'foo bar --opt yes', 'foo bar help']) do
      result = cli.execute_internal %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > .
my-command > my-command.
unknown action "my-command"
my-command > foo.
foo executed
my-command > foo bar.
bar executed
my-command > foo bar --opt yes.
bar executed
option: yes
my-command > foo bar help.
my-command foo bar

Available actions:
[ Type "help [action-name]" to get more information about that action ]

    help -- The help action for command "my-command foo bar" which provides details and usage information on how to use the command.
my-command > exit.
shell exited with code 0
      EOS
    end
  end

  it 'does not allow shell action if shell config is disabled' do
    cli = Cliqr.interface do
      name 'my-command'
      shell :disable
      arguments :disable
    end
    expect { cli.execute_internal %w(my-command shell) }.to(
      raise_error(Cliqr::Error::IllegalArgumentError, 'invalid command argument "shell"'))
  end

  it 'can handle errors in shell' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      arguments :disable

      action :foo do
        handler do
          fail StandardError, 'I failed!'
        end

        action :bar do
          handler TestCommand
        end
      end
    end

    with_input(['unknown', '--opt-1 val', 'foo']) do
      result = cli.execute_internal %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > unknown.
unknown action "unknown"
my-command > --opt-1 val.
unknown action "--opt-1"
my-command > foo.
command 'my-command foo' failed

Cause: StandardError - I failed!
my-command > exit.
shell exited with code 0
      EOS
    end
  end

  describe 'illegal shell operations' do
    it 'does not allow shell action if there are no sub-actions' do
      cli = Cliqr.interface do
        name 'my-command'
        help :disable
        handler TestCommand
        arguments :disable
      end
      expect { cli.execute_internal %w(my-command shell) }.to(
        raise_error(Cliqr::Error::IllegalArgumentError, 'invalid command argument "shell"'))
    end

    it 'does not allow shell in shell for base command' do
      cli = Cliqr.interface do
        name 'my-command'

        action :foo do
          action :bar
        end
      end

      with_input(['shell']) do
        result = cli.execute_internal %w(my-command shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > shell.
command 'my-command shell' failed

Cause: Cliqr::Error::IllegalCommandError - Cannot run another shell within an already running shell
my-command > exit.
shell exited with code 0
        EOS
      end
    end

    it 'does not allow shell in shell for sub action' do
      cli = Cliqr.interface do
        name 'my-command'

        action :foo do
          action :bar
        end
      end

      expect { cli.execute_internal %w(my-command foo shell) }.to(
        raise_error(Cliqr::Error::CommandRuntimeError,
                    "command 'my-command foo' failed\n\nCause: Cliqr::Error::IllegalArgumentError - no arguments allowed for default help action\n"))

      with_input(['foo shell']) do
        result = cli.execute_internal %w(my-command shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > foo shell.
command 'my-command foo' failed

Cause: Cliqr::Error::IllegalArgumentError - no arguments allowed for default help action
my-command > exit.
shell exited with code 0
        EOS
      end
    end
  end

  describe 'shell prompt' do
    it 'allows a custom prompt string for shell prompt' do
      cli = Cliqr.interface do
        name 'my-command'
        handler TestCommand
        shell :enable do
          prompt 'test-prompt $ '
        end

        action :foo do
          handler do
            puts 'foo executed'
          end
        end
      end

      with_input(['', '', 'foo']) do
        result = cli.execute_internal %w(my-command shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
test-prompt $ .
test-prompt $ .
test-prompt $ foo.
foo executed
test-prompt $ exit.
shell exited with code 0
        EOS
      end
    end

    it 'allows a custom prompt function for shell prompt' do
      cli = Cliqr.interface do
        name 'my-command'
        handler TestCommand
        shell :enable do
          count = 0
          prompt do
            count += 1
            "my-command [#{count}]$ "
          end
        end

        action :foo do
          handler do
            puts 'foo executed'
          end
        end
      end

      with_input(['', '', 'foo', '']) do
        result = cli.execute_internal %w(my-command shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command [1]$ .
my-command [2]$ .
my-command [3]$ foo.
foo executed
my-command [4]$ .
my-command [5]$ exit.
shell exited with code 0
        EOS
      end
    end

    it 'allows a custom prompt class for shell prompt' do
      cli = Cliqr.interface do
        name 'my-command'
        handler TestCommand
        shell :enable do
          prompt TestShellPrompt
        end

        action :foo do
          handler do
            puts 'foo executed'
          end
        end
      end

      with_input(['', '', 'foo', '']) do
        result = cli.execute_internal %w(my-command shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
test-prompt [1] > .
test-prompt [2] > .
test-prompt [3] > foo.
foo executed
test-prompt [4] > .
test-prompt [5] > exit.
shell exited with code 0
        EOS
      end
    end
  end
end

def with_input(lines, &block)
  old_stdin = $stdin
  $stdin = TestIO.new(lines)
  block.call
ensure
  $stdin = old_stdin
end

# A test class for wrapping stdin
class TestIO
  def initialize(lines)
    @lines = lines.reverse
  end

  def gets
    input = "#{@lines.length > 0 ? @lines.pop : 'exit'}"
    puts "#{input}."
    "#{input}\n"
  end
end
