# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::CLI::Executor do
  it 'can execute help in command shell' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action :bla
    end

    with_input(['help']) do
      result = cli.execute %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > help.
my-command

USAGE:
    my-command [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my-command" along with its usage information.

Available actions:
[ Type "my-command help [action-name]" to get more information about that action ]

    bla

    shell -- Execute a shell in the context of "my-command" command.

    help -- The help action for command "my-command" which provides details and usage information on how to use the command.
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
          end
        end
      end
    end

    with_input(['', 'my-command', 'foo', 'foo bar', 'foo bar help']) do
      result = cli.execute %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > .
base command executed
my-command > my-command.
base command executed
my-command > foo.
foo executed
my-command > foo bar.
bar executed
my-command > foo bar help.
my-command foo bar

USAGE:
    my-command foo bar [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my-command foo bar" along with its usage information.

Available actions:
[ Type "my-command foo bar help [action-name]" to get more information about that action ]

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
    expect { cli.execute %w(my-command shell) }.to(
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
      result = cli.execute %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > unknown.
invalid command argument "unknown"
my-command > --opt-1 val.
unknown option "--opt-1"
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
      expect { cli.execute %w(my-command shell) }.to(
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
        result = cli.execute %w(my-command shell), output: :buffer
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

      with_input(['shell']) do
        result = cli.execute %w(my-command foo shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command foo"
my-command foo > shell.
command 'my-command foo shell' failed

Cause: Cliqr::Error::IllegalCommandError - Cannot run another shell within an already running shell
my-command foo > exit.
shell exited with code 0
        EOS
      end

      with_input(['foo shell']) do
        result = cli.execute %w(my-command shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
my-command > foo shell.
command 'my-command foo shell' failed

Cause: Cliqr::Error::IllegalCommandError - Cannot run another shell within an already running shell
my-command > exit.
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
