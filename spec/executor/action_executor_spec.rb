# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'
require 'fixtures/always_error_command'
require 'fixtures/action_reader_command'
require 'fixtures/test_option_reader_command'
require 'fixtures/test_option_checker_command'
require 'fixtures/argument_reader_command'

describe Cliqr::CLI::Executor do
  it 'routes to action command with no arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand
      end
    end
    result = cli.execute ['my-action'], output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'handles error appropriately for an action' do
    cli = Cliqr.interface do
      name 'my-command'
      handler AlwaysErrorCommand

      action 'my-action-1' do
        handler AlwaysErrorCommand

        action 'my-action-2' do
          handler AlwaysErrorCommand
        end
      end
    end
    expect { cli.execute_internal %w(my-action-1 my-action-2) }.to raise_error(Cliqr::Error::CommandRuntimeError,
                                                                               "command 'my-command my-action-1 my-action-2' failed\n\nCause: StandardError - I always throw an error\n")
  end

  it 'routes to a action with option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler TestCommand

        option 'test-option'
      end
    end
    result = cli.execute %w(my-action --test-option some-value), output: :buffer
    expect(result[:stdout]).to eq "test command executed\n"
  end

  it 'lets a action command get all option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      action 'my-action' do
        handler ActionReaderCommand

        option 'test-option-1'
        option 'test-option-2'
      end
    end
    result = cli.execute %w(my-action --test-option-1 some-value --test-option-2 v2), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
command = my-command my-action

executing action = my-action
[option] test-option-1 => some-value
[option] test-option-2 => v2
    EOS
  end

  it 'lets a deeply nested action command get all option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler ActionReaderCommand

      action 'my-action-1' do
        handler ActionReaderCommand

        action 'my-action-2' do
          handler ActionReaderCommand

          action 'my-action-3' do
            handler ActionReaderCommand

            option 'test-option-1'
            option 'test-option-2'
          end
        end
      end
    end
    result = cli.execute %w(my-action-1 --test-option-1 some-value my-action-2 --test-option-2 v2 my-action-3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
command = my-command my-action-1 my-action-2 my-action-3

executing action = my-action-3
[option] test-option-1 => some-value
[option] test-option-2 => v2
    EOS
  end

  it 'does not depend on the order of action and option' do
    cli = Cliqr.interface do
      name 'my-command'
      handler ActionReaderCommand

      action 'my-action' do
        handler ActionReaderCommand

        option 'test-option'
      end
    end
    result = cli.execute %w(--test-option some-value my-action), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
command = my-command my-action

executing action = my-action
[option] test-option => some-value
    EOS
  end

  it 'lets a action command get single option value' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      action 'my-action' do
        handler TestOptionReaderCommand
        option 'test-option'
      end
    end
    result = cli.execute %w(my-action --test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
some-value
    EOS
  end

  it 'lets different action commands get their own option values' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionReaderCommand

      action 'my-action' do
        handler TestOptionReaderCommand
        option 'test-option'
      end

      action 'another-action' do
        handler TestOptionReaderCommand
        option 'test-option'
      end

      action 'third-action' do
        handler ActionReaderCommand
        option 'third-option'
      end
    end
    result = cli.execute %w(my-action --test-option some-value), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
some-value
    EOS

    result = cli.execute %w(another-action --test-option another), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
another
    EOS

    result = cli.execute %w(third-action --third-option 3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
command = my-command third-action

executing action = third-action
[option] third-option => 3
    EOS
  end

  it 'allows action command to access argument list' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestOptionCheckerCommand

      action 'my-action' do
        handler ArgumentReaderCommand
        arguments :enable

        option 'test-option'
      end
    end

    result = cli.execute %w(my-action value1 --test-option qwerty value2 value3), output: :buffer
    expect(result[:stdout]).to eq <<-EOS
value1
value2
value3
    EOS
  end
end
