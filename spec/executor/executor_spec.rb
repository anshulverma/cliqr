# encoding: utf-8

require 'spec_helper'

require 'cliqr/error'

require 'fixtures/test_command'
require 'fixtures/always_error_command'
require 'fixtures/option_reader_command'
require 'fixtures/test_option_reader_command'
require 'fixtures/test_option_checker_command'
require 'fixtures/argument_reader_command'
require 'fixtures/test_option_type_checker_command'
require 'fixtures/csv_argument_operator'

describe Cliqr::CLI::Executor do
  it 'returns code 0 for default command runner' do
    expect(Cliqr.command.new.execute(nil)).to eq(0)
  end

  it 'routes base command with no arguments to command class' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
    end
    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'routes base command with no arguments to command instance' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand.new
    end
    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'handles error appropriately' do
    cli = Cliqr.interface do
      name 'my-command'
      handler AlwaysErrorCommand
    end
    expect { cli.execute [] }.to(
      raise_error(Cliqr::Error::CommandRuntimeException,
                  "command 'my-command' failed\n\nCause: StandardError - I always throw an error\n"))
  end

  it 'routes a command with option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'lets a command get all option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler OptionReaderCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
my-command

[option] test-option => some-value
    EOS
  end

  it 'lets a command get single option value' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      option 'test-option'
    end
    result = cli.execute %w(--test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
some-value
    EOS
  end

  it 'handles executor error cause properly' do
    cli = Cliqr.interface do
      name 'my-command'
      handler AlwaysErrorCommand
    end
    begin
      cli.execute
    rescue Cliqr::Error::CliqrError => e
      expect(e.backtrace[0]).to end_with "cliqr/spec/fixtures/always_error_command.rb:6:in `execute'"
      expect(e.message).to eq "command 'my-command' failed\n\nCause: StandardError - I always throw an error\n"
    end
  end

  it 'allows command to check if an option exists or not' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestOptionCheckerCommand

      option 'test-option' do
        type :boolean
      end
    end

    result = cli.execute %w(--test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is defined
    EOS
  end

  it 'allows command to access argument list' do
    cli = Cliqr.interface do
      name 'my-command'
      handler ArgumentReaderCommand
      arguments :enable

      option 'test-option'
    end

    result = cli.execute %w(value1 --test-option qwerty value2 value3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
value1
value2
value3
    EOS
  end

  it 'properly handles string type arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionTypeCheckerCommand

      option 'test-option'
    end

    result = cli.execute %w(--test-option qwerty), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type String
    EOS
  end

  it 'properly handles boolean type arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionTypeCheckerCommand

      option 'test-option' do
        type :boolean
      end
    end

    result = cli.execute %w(--test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type TrueClass
    EOS

    result = cli.execute %w(--no-test-option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type FalseClass
    EOS
  end

  it 'properly handles integer type arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionTypeCheckerCommand

      option 'test-option' do
        type :numeric
      end
    end

    result = cli.execute %w(--test-option 123), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
test-option is of type Fixnum
    EOS
  end

  it 'allows custom argument operators' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        operator CSVArgumentOperator
      end
    end

    result = cli.execute %w(--test-option a,b,c,d), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
a
b
c
d
    EOS
  end

  it 'allows inline executor' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts "value = #{option('test-option').value}"
      end

      option 'test-option'
    end

    result = cli.execute %w(--test-option executor-inline), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
value = executor-inline
    EOS
  end

  it 'allows inline argument operator' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      option 'test-option' do
        operator do
          "value = #{value}"
        end
      end
    end

    result = cli.execute %w(--test-option operator-inline), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
value = operator-inline
    EOS
  end

  it 'allows inline executor to access all context methods directly' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts 'in my-command'
        puts options.map { |option| "#{option.name} => #{option.value}" }
        puts action?
        puts option?('option-1')
        puts option?('option-2')
        puts option?('option-3')
      end

      option 'option-1'
      option 'option-2'

      action 'my-action' do
        handler do
          puts 'in my-action'
          puts options.map { |option| "#{option.name} => #{option.value}" }
          puts option('option-3').value
          puts action?
          puts option?('option-1')
          puts option?('option-2')
          puts option?('option-3')
        end

        option 'option-3'
      end
    end

    result = cli.execute %w(--option-1 val1 --option-2 val2), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
in my-command
option-1 => val1
option-2 => val2
false
true
true
false
    EOS

    result = cli.execute %w(my-action --option-3 val3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
in my-action
option-3 => val3
val3
true
false
false
true
    EOS
  end

  it 'allows inline executor to get option value by calling method' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
        puts second_option
      end

      option 'test_option'

      option 'second_option' do
        type :boolean
      end
    end

    result = cli.execute %w(--test_option executor-inline --second_option), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
executor-inline
true
true
    EOS

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS

false
false
    EOS
  end

  it 'makes false the default for boolean options' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option 'test_option' do
        type :boolean
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
false
false
    EOS
  end

  it 'can override default to true' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option 'test_option' do
        type :boolean
        default true
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
true
false
    EOS
  end

  it 'makes 0 as default for numerical' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option 'test_option' do
        type :numeric
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
0
false
    EOS
  end

  it 'allows non-zero default for numerical option' do
    cli = Cliqr.interface do
      name 'my-command'

      handler do
        puts test_option
        puts test_option?
      end

      option :test_option do
        type :numeric
        default 123
      end
    end

    result = cli.execute [], output: :buffer
    expect(result[:stdout]).to eq <<-EOS
123
false
    EOS
  end

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

      action :action_1 do
        description 'test action'
        handler TestCommand
      end

      action 'action_2' do
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
