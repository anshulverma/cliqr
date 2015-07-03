# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'
require 'fixtures/test_shell_prompt'
require 'fixtures/test_color_shell_prompt'
require 'fixtures/test_shell_banner'

describe Cliqr::Command::ShellCommand do
  it 'can execute help in command shell' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'this is a test command'
      color :disable

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
[my-command][1] $ help.
my-command -- this is a test command

Available actions:
[ Type "help [action-name]" to get more information about that action ]

    foo -- the foo action
    bar -- bar command
    help -- The help action for command "my-command" which provides details and usage information on how to use the command.
[my-command][2] $ -h.
unknown action "-h"
[my-command][3] $ exit.
shell exited with code 0
      EOS
    end

    with_input(['help bar']) do
      result = cli.execute_internal %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
[my-command][4] $ help bar.
my-command bar -- bar command

Available actions:
[ Type "help [action-name]" to get more information about that action ]

    baz
    help -- The help action for command "my-command bar" which provides details and usage information on how to use the command.
[my-command][5] $ exit.
shell exited with code 0
      EOS
    end
  end

  it 'can execute a sub action from shell' do
    cli = Cliqr.interface do
      name 'my-command'
      color :disable

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
[my-command][1] $ .
[my-command][2] $ my-command.
unknown action "my-command"
[my-command][3] $ foo.
foo executed
[my-command][4] $ foo bar.
bar executed
[my-command][5] $ foo bar --opt yes.
bar executed
option: yes
[my-command][6] $ foo bar help.
my-command foo bar

Available actions:
[ Type "help [action-name]" to get more information about that action ]

    help -- The help action for command "my-command foo bar" which provides details and usage information on how to use the command.
[my-command][7] $ exit.
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
      arguments :disable
      color :disable

      action :foo do
        handler do
          fail StandardError, 'I failed!'
        end

        action :bar
      end
    end

    with_input(['unknown', '--opt-1 val', 'foo']) do
      result = cli.execute_internal %w(my-command shell), output: :buffer
      expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
[my-command][1] $ unknown.
unknown action "unknown"
[my-command][2] $ --opt-1 val.
unknown action "--opt-1"
[my-command][3] $ foo.
command 'my-command foo' failed

Cause: StandardError - I failed!
[my-command][4] $ exit.
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
        color :disable

        action :foo do
          action :bar
        end
      end

      with_input(['shell']) do
        result = cli.execute_internal %w(my-command shell), output: :buffer
        expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
[my-command][1] $ shell.
command 'my-command shell' failed

Cause: Cliqr::Error::IllegalCommandError - Cannot run another shell within an already running shell
[my-command][2] $ exit.
shell exited with code 0
        EOS
      end
    end

    it 'does not allow shell in shell for sub action' do
      cli = Cliqr.interface do
        name 'my-command'
        color :disable

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
[my-command][1] $ foo shell.
command 'my-command foo' failed

Cause: Cliqr::Error::IllegalArgumentError - no arguments allowed for default help action
[my-command][2] $ exit.
shell exited with code 0
        EOS
      end
    end
  end

  describe Cliqr::Command::ShellPromptBuilder do
    it 'allows a custom prompt string for shell prompt' do
      cli = Cliqr.interface do
        name 'my-command'
        color :disable
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
        color :disable
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
        color :disable
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

    it 'allows a default prompt' do
      cli = Cliqr.interface do
        name 'my-command'
        color :disable
        shell :enable

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
[my-command][1] $ .
[my-command][2] $ .
[my-command][3] $ foo.
foo executed
[my-command][4] $ .
[my-command][5] $ exit.
shell exited with code 0
        EOS
      end
    end

    describe 'prompt colors' do
      it 'can show colors using default prompt builder' do
        cli = Cliqr.interface do
          name 'my-command'
          arguments :disable

          action :foo do
            handler do
              fail StandardError, 'I failed!'
            end

            action :bar
          end
        end

        with_input(['unknown', '--opt-1 val', 'foo']) do
          result = cli.execute_internal %w(my-command shell), output: :buffer
          expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
[[36mmy-command[0m][1] [1m$[22m unknown.
unknown action "unknown"
[[36mmy-command[0m][2] [1m$[22m --opt-1 val.
unknown action "--opt-1"
[[36mmy-command[0m][3] [1m$[22m foo.
command 'my-command foo' failed

Cause: StandardError - I failed!
[[36mmy-command[0m][4] [1m$[22m exit.
shell exited with code 0
          EOS
        end
      end

      it 'can show colors using custom prompt builder' do
        cli = Cliqr.interface do
          name 'my-command'
          arguments :disable

          shell do
            prompt TestColorShellPrompt
          end

          action :foo do
            handler do
              fail StandardError, 'I failed!'
            end

            action :bar
          end
        end

        with_input(['unknown', '--opt-1 val', 'foo']) do
          result = cli.execute_internal %w(my-command shell), output: :buffer
          expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
[31mtest-prompt [1] > [0munknown.
unknown action "unknown"
[31mtest-prompt [2] > [0m--opt-1 val.
unknown action "--opt-1"
[31mtest-prompt [3] > [0mfoo.
command 'my-command foo' failed

Cause: StandardError - I failed!
[31mtest-prompt [4] > [0mexit.
shell exited with code 0
          EOS
        end
      end

      it 'can show colors using custom prompt builder' do
        cli = Cliqr.interface do
          name 'my-command'
          arguments :disable

          shell do
            prompt do
              green('green prompt > ')
            end
          end

          action :foo do
            handler do
              fail StandardError, 'I failed!'
            end

            action :bar
          end
        end

        with_input(['unknown', '--opt-1 val', 'foo']) do
          result = cli.execute_internal %w(my-command shell), output: :buffer
          expect(result[:stdout]).to eq <<-EOS
Starting shell for command "my-command"
[32mgreen prompt > [0munknown.
unknown action "unknown"
[32mgreen prompt > [0m--opt-1 val.
unknown action "--opt-1"
[32mgreen prompt > [0mfoo.
command 'my-command foo' failed

Cause: StandardError - I failed!
[32mgreen prompt > [0mexit.
shell exited with code 0
          EOS
        end
      end
    end
  end

  describe Cliqr::Command::ShellBannerBuilder do
    it 'allows a custom prompt string for shell banner' do
      cli = Cliqr.interface do
        name 'my-command'
        color :disable
        shell :enable do
          banner 'Welcome to my-command!!!'
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
Welcome to my-command!!!
[my-command][6] $ .
[my-command][7] $ .
[my-command][8] $ foo.
foo executed
[my-command][9] $ exit.
shell exited with code 0
        EOS
      end
    end

    it 'allows a custom prompt function for shell banner' do
      cli = Cliqr.interface do
        name 'my-command'
        color :disable
        shell :enable do
          banner do
            "welcome to #{command}"
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
welcome to my-command
[my-command][10] $ .
[my-command][11] $ .
[my-command][12] $ foo.
foo executed
[my-command][13] $ .
[my-command][14] $ exit.
shell exited with code 0
        EOS
      end
    end

    it 'allows a custom prompt class for shell banner' do
      cli = Cliqr.interface do
        name 'my-command'
        color :disable
        shell :enable do
          banner TestShellBanner
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
welcome to the command my-command
[my-command][15] $ .
[my-command][16] $ .
[my-command][17] $ foo.
foo executed
[my-command][18] $ .
[my-command][19] $ exit.
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
