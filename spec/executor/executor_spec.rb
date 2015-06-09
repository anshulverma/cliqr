# encoding: utf-8

require 'spec_helper'

require 'cliqr/error'

require 'fixtures/test_command'
require 'fixtures/always_error_command'
require 'fixtures/option_reader_command'
require 'fixtures/test_option_reader_command'
require 'fixtures/test_option_checker_command'
require 'fixtures/argument_reader_command'

describe Cliqr::CLI::Executor do
  it 'returns code 0 for default command runner' do
    expect(Cliqr.command.new.execute).to eq(0)
  end

  it 'routes base command with no arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
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
end
