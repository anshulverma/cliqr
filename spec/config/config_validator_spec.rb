# encoding: utf-8

require 'spec_helper'

require 'cliqr/cli/option_config_validator'

require 'fixtures/test_command'

describe Cliqr::CLI::Config do
  it 'does not allow empty basename' do
    expect do
      Cliqr.interface do
        basename ''
        handler TestCommand
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - ['basename' cannot be empty]"))
  end

  it 'does not allow nil basename' do
    expect do
      Cliqr.interface do
        basename nil
        handler TestCommand
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - ['basename' cannot be nil]"))
  end

  it 'does not allow invalid characters in basename' do
    expect do
      Cliqr.interface do
        basename 'invalid-char-!'
        handler TestCommand
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [value for 'basename' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-char-!\"]"))
  end

  it 'does not allow command handler to be null' do
    expect do
      Cliqr.interface do
        basename 'my-command'
      end
    end.to(raise_error(Cliqr::Error::ValidationError, "invalid Cliqr interface configuration - ['handler' cannot be nil]"))
  end

  it 'only accepts command handler that extend from Cliqr::CLI::Command' do
    expect do
      Cliqr.interface do
        basename 'my-command'
        handler Object
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [value 'Object' of type 'Class' for 'handler' does not extend from 'Cliqr::CLI::Command']"))
  end

  it 'expects that config options should not be nil' do
    config = Cliqr::CLI::Config.new
    config.basename = 'my-command'
    config.handler = TestCommand
    config.options = nil
    config.finalize
    expect { Cliqr::CLI::Interface.build(config) }.to(
      raise_error(Cliqr::Error::ValidationError, "invalid Cliqr interface configuration - ['options' cannot be nil]"))
  end

  it 'throws multiple errors if more than one issue exists in config' do
    expect do
      Cliqr.interface do
        basename 'invalid-name-!@#'
        handler Object
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [value for 'basename' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-name-!@#\", " \
                       "value 'Object' of type 'Class' for 'handler' does not extend from 'Cliqr::CLI::Command']"))
  end
end
