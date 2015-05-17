# encoding: utf-8

require 'spec_helper'

require 'cliqr/cli/config_validator'

require 'fixtures/test_command'

describe Cliqr::CLI::ConfigValidator do
  it 'does not allow empty config' do
    expect { Cliqr::CLI::Interface.build(nil) }.to(
        raise_error(Cliqr::Error::ConfigNotFound, 'a valid config should be defined')
    )
  end

  it 'does not allow empty basename' do
    config = Cliqr::CLI::Config.new
    config.basename = ''
    config.finalize
    expect { Cliqr::CLI::Interface.build(config) }.to(
        raise_error(Cliqr::Error::BasenameNotDefined, 'basename not defined')
    )
  end

  it 'does not allow command handler to be null' do
    config = Cliqr::CLI::Config.new
    config.basename = 'my-command'
    config.finalize
    expect { Cliqr::CLI::Interface.build(config) }.to(
        raise_error(Cliqr::Error::HandlerNotDefined, 'handler not defined for command "my-command"')
    )
  end

  it 'only accepts command handler that extend from Cliqr::CLI::Command' do
    config = Cliqr::CLI::Config.new
    config.basename = 'my-command'
    config.handler = Object
    config.finalize
    expect { Cliqr::CLI::Interface.build(config) }.to(
        raise_error(Cliqr::Error::InvalidCommandHandler,
                    'handler for command "my-command" should extend from [Cliqr::CLI::Command]')
    )
  end

  it 'expects that config options should not be nil' do
    config = Cliqr::CLI::Config.new
    config.basename = 'my-command'
    config.handler = TestCommand
    config.options = nil
    config.finalize
    expect { Cliqr::CLI::Interface.build(config) }.to(
        raise_error(Cliqr::Error::OptionsNotDefinedException, 'option array is nil for command "my-command"'),
    )
  end
end
