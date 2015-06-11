# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'
require 'fixtures/action_reader_command'

describe Cliqr::CLI::UsageBuilder do
  ################ BASE COMMAND ################

  it 'builds a base command with name' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand
      arguments :disable
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command
    EOS
  end

  it 'only makes name and handler to be required' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      arguments :disable
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command
    EOS
  end

  ################ OPTION ################

  it 'allows options for a command' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand
      arguments :disable

      option 'option-1' do
        short 'p'
        description 'a nice option to have'
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command [options]

Available options:

    --option-1, -p  :  a nice option to have
    EOS
  end

  it 'allows command options to optionally have description, type and short name' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand
      arguments :disable

      option 'option-1'
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command [options]

Available options:

    --option-1
    EOS
  end

  it 'has options if added during build phase' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand

      option 'option-1' do
        short 'p'
        description 'a nice option to have'
      end
    end
    expect(cli.config.options?).to be_truthy
  end

  ################ OPTION TYPES ################

  it 'allows command options to have a numeric value type' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand
      arguments :disable

      option 'option-1' do
        description 'a numeric option'
        short 'p'
        type :numeric
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command [options]

Available options:

    --option-1, -p  :  <numeric> a numeric option (default => 0)
    EOS
  end

  it 'allows command options to have a boolean value type' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand
      arguments :disable

      option 'option-1' do
        description 'a boolean option'
        short 'p'
        type :boolean
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command [options]

Available options:

    --[no-]option-1, -p  :  <boolean> a boolean option (default => false)
    EOS
  end

  it 'allows command options to have a boolean value type and no description' do
    cli = Cliqr.interface do
      name 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand
      arguments :disable

      option 'option-1' do
        short 'p'
        type :boolean
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command [options]

Available options:

    --[no-]option-1, -p  :  <boolean> (default => false)
    EOS
  end

  ################ ARGUMENTS ################

  it 'allows interface to enable arbitrary argument list parsing without options' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      arguments :enable
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [arguments]
    EOS
  end

  it 'allows interface to enable arbitrary argument list parsing' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      arguments :enable

      option 'option-1'
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [options] [arguments]

Available options:

    --option-1
    EOS
  end

  ################ ACTIONS ################

  it 'allows command to have an action' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand
        arguments :disable
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [actions] [arguments]

Available actions:

    my-action
    EOS
  end

  it 'allows command to have an action with description' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand
        description 'this is a test action'
        arguments :disable
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [actions] [arguments]

Available actions:

    my-action -- this is a test action
    EOS
  end

  it 'allows command to have an action and an option' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand
        description 'this is a test action'
        arguments :disable
      end

      option 'option-1'
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [actions] [options] [arguments]

Available options:

    --option-1

Available actions:

    my-action -- this is a test action
    EOS
  end

  it 'allows command to have an action with options' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand
        description 'this is a test action'

        option 'action-option'
      end

      option 'option-1'
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [actions] [options] [arguments]

Available options:

    --option-1

Available actions:

    my-action -- this is a test action
    Type "my-command help my-action" to get more information about action "my-action"
    EOS
  end

  it 'allows command to have multiple actions and multiple options' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option 'option-1'

      action 'my-action' do
        handler TestCommand
        description 'this is a test action'

        option 'action-option'
      end

      option 'option-2'

      action 'another-action' do
        handler TestCommand
        description 'this is another test action'
        arguments :disable
      end

      option 'option-3'
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [actions] [options] [arguments]

Available options:

    --option-1
    --option-2
    --option-3

Available actions:

    my-action -- this is a test action
    Type "my-command help my-action" to get more information about action "my-action"

    another-action -- this is another test action
    EOS
  end

  it 'allows nested actions with a mix of same options and same names' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        handler TestCommand

        option 'test-option-1'
        option 'test-option-2'

        action 'my-action-1' do
          handler ActionReaderCommand

          action 'my-action-1' do
            handler ActionReaderCommand

            option 'test-option-1'
            option 'test-option-2'

            action 'my-action-1' do
              handler ActionReaderCommand

              option 'test-option-1'
              option 'test-option-2'
            end
          end
        end

        action 'another-action' do
          handler ActionReaderCommand
          arguments :disable
        end
      end
    end
    expect(define_interface.usage).to eq <<-EOS
my-command

USAGE:
    my-command [actions] [options] [arguments]

Available options:

    --test-option-1
    --test-option-2

Available actions:

    my-action-1
    Type "my-command help my-action-1" to get more information about action "my-action-1"

    another-action
    EOS
  end

  ################ DEFAULT OPTION VALUES ################

  it 'allows options to have default value' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option 'test-option' do
        default :a_symbol
      end

      option :another do
        short 'a'
        description 'another option'
        type :numeric
        default %w(test array default)

        operator CSVArgumentOperator
      end

      option 'nil-option' do
        default nil
      end

      option 'string-option' do
        default 'string'
      end

      option 'hash-option' do
        default(:key => 'val')
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [options] [arguments]

Available options:

    --test-option  :  (default => :a_symbol)
    --another, -a  :  <numeric> another option (default => [\"test\", \"array\", \"default\"])
    --nil-option
    --string-option  :  (default => "string")
    --hash-option  :  (default => {:key=>"val"})
    EOS
  end

  it 'boolean option is false by default' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option :another do
        short 'a'
        description 'another option'
        type :boolean

        operator CSVArgumentOperator
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [options] [arguments]

Available options:

    --[no-]another, -a  :  <boolean> another option (default => false)
    EOS
  end

  it 'numeric option is 0 by default' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option :another do
        short 'a'
        description 'another option'
        type :numeric

        operator CSVArgumentOperator
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [options] [arguments]

Available options:

    --another, -a  :  <numeric> another option (default => 0)
    EOS
  end

  it 'boolean option can be made default true' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option :another do
        short 'a'
        description 'another option'
        type :boolean
        default true

        operator CSVArgumentOperator
      end
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command [options] [arguments]

Available options:

    --[no-]another, -a  :  <boolean> another option (default => true)
    EOS
  end
end
