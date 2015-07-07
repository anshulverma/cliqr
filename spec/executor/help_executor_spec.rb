# encoding: utf-8

require 'spec_helper'

require 'cliqr/error'

require 'fixtures/test_command'

describe Cliqr::Executor do
  it 'can execute help action to get help for base command' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'test command has no description'
      color :disable
    end

    result = cli.execute_internal ['help'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my-command -- test command has no description

USAGE:
    my-command [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my-command" along with its usage information.

Available actions:
[ Type "my-command help [action-name]" to get more information about that action ]

    help -- The help action for command "my-command" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can execute help action to get help for a action' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      color :disable

      action :action_1 do
        description 'test action'

        action :sub_action do
          description 'This is a sub action.'
        end

        option :temp do
          description 'temporary option'
        end
      end

      action :action_2 do
        description 'another cool action for the base command'
      end
    end

    result = cli.execute_internal %w(help action_1), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command action_1 -- test action

USAGE:
    my_command action_1 [actions] [options] [arguments]

Available options:

    --temp  :  temporary option
    --help, -h  :  Get helpful information for action "my_command action_1" along with its usage information.

Available actions:
[ Type "my_command action_1 help [action-name]" to get more information about that action ]

    sub_action -- This is a sub action.
    help -- The help action for command "my_command action_1" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can use help option to get help for a action' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      color :disable

      action :action_1 do
        description 'test action'

        action :sub_action do
          description 'This is a sub action.'
        end

        option :temp do
          description 'temporary option'
        end
      end

      action :action_2 do
        description 'another cool action for the base command'
      end
    end

    result = cli.execute_internal %w(action_2 --help), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command action_2 -- another cool action for the base command

USAGE:
    my_command action_2 [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my_command action_2" along with its usage information.

Available actions:
[ Type "my_command action_2 help [action-name]" to get more information about that action ]

    help -- The help action for command "my_command action_2" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can execute help action to get help for base command with multiple actions' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      shell :disable
      color :disable

      action :action_1 do
        description 'test action'

        action :sub_action do
          description 'This is a sub action.'
        end

        option :temp do
          description 'temporary option'
        end
      end

      action :action_2 do
        description 'another cool action for the base command'
      end
    end

    result = cli.execute_internal %w(help), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command -- test command has no description

USAGE:
    my_command [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my_command" along with its usage information.

Available actions:
[ Type "my_command help [action-name]" to get more information about that action ]

    action_1 -- test action
    action_2 -- another cool action for the base command
    help -- The help action for command "my_command" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can execute help option to get help for base command' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'test command has no description'
      color :disable
    end

    result = cli.execute_internal ['--help'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my-command -- test command has no description

USAGE:
    my-command [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my-command" along with its usage information.

Available actions:
[ Type "my-command help [action-name]" to get more information about that action ]

    help -- The help action for command "my-command" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can execute help option to get help for a action' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      color :disable

      action :action_1
    end

    result = cli.execute_internal %w(--help action_1), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command action_1

USAGE:
    my_command action_1 [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my_command action_1" along with its usage information.

Available actions:
[ Type "my_command action_1 help [action-name]" to get more information about that action ]

    help -- The help action for command "my_command action_1" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can execute help action on the action itself to get help for a action' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      color :disable

      action :action_1 do
        description 'test action'
      end
    end

    result = cli.execute_internal %w(action_1 help), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command action_1 -- test action

USAGE:
    my_command action_1 [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my_command action_1" along with its usage information.

Available actions:
[ Type "my_command action_1 help [action-name]" to get more information about that action ]

    help -- The help action for command "my_command action_1" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can execute help action on itself' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      color :disable

      action :action_1 do
        description 'test action'
      end
    end

    result = cli.execute_internal %w(help help), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command help -- The help action for command "my_command" which provides details and usage information on how to use the command.

USAGE:
    my_command help [arguments]
    EOS
  end

  it 'does not allow help action to take more than one argument' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'

      action :action_1 do
        description 'test action'
      end
    end

    expect { cli.execute_internal %w(help action_1 arg2), output: :buffer }.to(
      raise_error(Cliqr::Error::CommandRuntimeError,
                  "command 'my_command help' failed\n\n" \
                  "Cause: Cliqr::Error::IllegalArgumentError - too many arguments for \"my_command help\" command\n"))
  end

  it 'executes help for action without handler' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      shell :disable
      color :disable

      action :action_1 do
        description 'test action'
      end

      action 'action_2' do
        action 'sub-action'
      end
    end

    result = cli.execute_internal %w(my_command), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command -- test command has no description

USAGE:
    my_command [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my_command" along with its usage information.

Available actions:
[ Type "my_command help [action-name]" to get more information about that action ]

    action_1 -- test action
    action_2
    help -- The help action for command "my_command" which provides details and usage information on how to use the command.
    EOS

    result = cli.execute_internal %w(my_command action_2), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my_command action_2

USAGE:
    my_command action_2 [actions] [options] [arguments]

Available options:

    --help, -h  :  Get helpful information for action "my_command action_2" along with its usage information.

Available actions:
[ Type "my_command action_2 help [action-name]" to get more information about that action ]

    sub-action
    help -- The help action for command "my_command action_2" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can display help in color' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'

      action :foo do
        description 'test action'

        action :bar do
          description 'this is a bar'

          option :opt1 do
            type :numeric
            default 123
            description 'a temporary option'
          end
        end
      end
    end

    result = cli.execute_internal %w(foo help bar), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
[30mmy_command foo[0m [1m[33mbar[0m[22m -- this is a bar

[1mUSAGE:[22m
    my_command foo bar [actions] [options] [arguments]

[1mAvailable options:[22m

    --opt1  :  <numeric> a temporary option (default => 123)
    --help, -h  :  Get helpful information for action "my_command foo bar" along with its usage information.

[1mAvailable actions:[22m
[30m[ Type "my_command foo bar help [action-name]" to get more information about that action ]
[0m
    [32mhelp[0m -- The help action for command "my_command foo bar" which provides details and usage information on how to use the command.
    EOS
  end

  it 'can use options in shell config' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      color :disable

      shell do
        name 'b00m'
        description 'this is a custom shell implementation'

        option :foo

        option :bar do
          type :boolean
          default true
          description 'some bar'
        end

        option :baz do
          type :numeric
          default 10
        end
      end
    end

    result = cli.execute_internal %w(help b00m), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my-command b00m -- this is a custom shell implementation

USAGE:
    my-command b00m [options] [arguments]

Available options:

    --foo
    --[no-]bar  :  <boolean> some bar (default => true)
    --baz  :  <numeric> (default => 10)
    EOS
  end
end
