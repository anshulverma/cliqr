# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::CLI::Interface do
  it 'does not allow empty config' do
    expect do
      Cliqr::CLI::Interface.build(nil)
    end.to(raise_error(Cliqr::Error::ConfigNotFound, 'a valid config should be defined'))
  end

  it 'builds a base command with name' do
    cli = Cliqr.interface do
      basename 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand
    end

    expect(cli.usage).to eq <<-EOS
my-command -- a command used to test cliqr

USAGE:
    my-command
EOS
  end

  it 'only makes basename and handler to be required' do
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestCommand
    end

    expect(cli.usage).to eq <<-EOS
my-command

USAGE:
    my-command
EOS
  end

  it 'allows options for a command' do
    cli = Cliqr.interface do
      basename 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand

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
      basename 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand

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
      basename 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand

      option 'option-1' do
        short 'p'
        description 'a nice option to have'
      end
    end
    expect(cli.config.options?).to be_truthy
  end

  it 'allows command options to have a numeric value type' do
    cli = Cliqr.interface do
      basename 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand

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

    --option-1, -p  :  <numeric> a numeric option
    EOS
  end

  it 'allows command options to have a boolean value type' do
    cli = Cliqr.interface do
      basename 'my-command'
      description 'a command used to test cliqr'
      handler TestCommand

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

    --[no-]option-1, -p  :  <boolean> a boolean option
    EOS
  end
end
