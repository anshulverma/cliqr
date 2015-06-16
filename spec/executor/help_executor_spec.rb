# encoding: utf-8

require 'spec_helper'

require 'cliqr/error'

require 'fixtures/test_command'

describe Cliqr::CLI::Executor do
  it 'can execute help action to get help for base command' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'test command has no description'
      handler TestCommand
    end

    result = cli.execute ['help'], output: :buffer
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

  it 'can execute help option to get help for base command' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'test command has no description'
      handler TestCommand
    end

    result = cli.execute ['--help'], output: :buffer
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
      handler TestCommand

      action :action_1 do
        description 'test action'
        handler TestCommand
        shell :disable

        action :sub_action do
          description 'This is a sub action.'
          handler TestCommand
        end

        option :temp do
          description 'temporary option'
        end
      end

      action :action_2 do
        description 'another cool action for the base command'
        handler TestCommand
      end
    end

    result = cli.execute %w(help action_1), output: :buffer
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
      handler TestCommand

      action :action_1 do
        description 'test action'
        handler TestCommand

        action :sub_action do
          description 'This is a sub action.'
          handler TestCommand
        end

        option :temp do
          description 'temporary option'
        end
      end

      action :action_2 do
        description 'another cool action for the base command'
        handler TestCommand
      end
    end

    result = cli.execute %w(action_2 --help), output: :buffer
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
      handler TestCommand
      shell :disable

      action :action_1 do
        description 'test action'
        handler TestCommand

        action :sub_action do
          description 'This is a sub action.'
          handler TestCommand
        end

        option :temp do
          description 'temporary option'
        end
      end

      action :action_2 do
        description 'another cool action for the base command'
        handler TestCommand
      end
    end

    result = cli.execute %w(help), output: :buffer
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
      handler TestCommand
    end

    result = cli.execute ['--help'], output: :buffer
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
      handler TestCommand

      action :action_1 do
        handler TestCommand
      end
    end

    result = cli.execute %w(--help action_1), output: :buffer
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
      handler TestCommand

      action :action_1 do
        description 'test action'
        handler TestCommand
      end
    end

    result = cli.execute %w(action_1 help), output: :buffer
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
      handler TestCommand

      action :action_1 do
        description 'test action'
        handler TestCommand
      end
    end

    result = cli.execute %w(help help), output: :buffer
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
      handler TestCommand

      action :action_1 do
        description 'test action'
        handler TestCommand
      end
    end

    expect { cli.execute %w(help action_1 arg2), output: :buffer }.to(
      raise_error(Cliqr::Error::CommandRuntimeException,
                  "command 'my_command help' failed\n\n" \
                  "Cause: Cliqr::Error::IllegalArgumentError - too many arguments for \"my_command help\" command\n"))
  end

  it 'can forward command to another action' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      handler TestCommand

      action :action_1 do
        description 'test action'
        handler do
          puts 'in action_1'
          forward 'my_command action_2 sub-action' # starting with base command name
          puts 'back in action_1'
        end
      end

      action 'action_2' do
        handler do
          puts 'in action_2'
        end

        action 'sub-action' do
          handler do
            puts 'in sub-action'
            forward 'action_2' # not starting with base command name
            puts 'back in sub-action'
          end
        end
      end
    end

    result = cli.execute ['action_1'], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
in action_1
in sub-action
in action_2
back in sub-action
back in action_1
    EOS
  end

  it 'executes help for action without handler' do
    cli = Cliqr.interface do
      name :my_command
      description 'test command has no description'
      shell :disable

      action :action_1 do
        description 'test action'
        handler TestCommand
      end

      action 'action_2' do
        shell :disable

        action 'sub-action' do
          handler TestCommand
        end
      end
    end

    result = cli.execute %w(my_command), output: :buffer
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

    result = cli.execute %w(my_command action_2), output: :buffer
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
end
