# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::CLI::Interface do
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

  it 'allows command options to optionally have description and short name' do
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

  it 'does not allow multiple options with same long name' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          short 'p'
        end

        option 'option-1' do
          short 't'
        end
      end
    end.to(raise_error(Cliqr::Error::DuplicateOptions, 'multiple options with long name "option-1"'))
  end

  it 'does not allow multiple options with same short name' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          short 'p'
        end

        option 'option-1' do
          short 't'
        end
      end
    end.to(raise_error(Cliqr::Error::DuplicateOptions, 'multiple options with long name "option-1"'))
  end

  it 'does not allow multiple options with same short name' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          short 'p'
        end

        option 'option-2' do
          short 'p'
        end
      end
    end.to(raise_error(Cliqr::Error::DuplicateOptions, 'multiple options with short name "p"'))
  end

  it 'does not allow option with empty long name' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option '' do
          short 'p'
        end
      end
    end.to(raise_error(Cliqr::Error::InvalidOptionDefinition, 'option number 1 does not have a name field'))
  end

  it 'does not allow option with empty short name' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          short ''
        end
      end
    end.to(raise_error(Cliqr::Error::InvalidOptionDefinition, "option \"option-1\" has empty short name"))
  end

  it 'does not allow option with nil long name' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option nil
      end
    end.to(raise_error(Cliqr::Error::InvalidOptionDefinition, 'option number 1 does not have a name field'))
  end

  it 'does not allow option with nil long name for second option' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1'
        option ''
      end
    end.to(raise_error(Cliqr::Error::InvalidOptionDefinition, 'option number 2 does not have a name field'))
  end

  it 'does not allow multiple characters in short name' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          short 'p1'
        end
      end
    end.to(raise_error(Cliqr::Error::InvalidOptionDefinition,
                       'short option name can not have more than one characters in "option-1"'))
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
end
