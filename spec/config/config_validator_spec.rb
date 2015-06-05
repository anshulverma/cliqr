# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::CLI::Config do
  it 'does not allow empty name' do
    expect do
      Cliqr.interface do
        name ''
        handler TestCommand
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - ['name' cannot be empty]"))
  end

  it 'does not allow nil name' do
    expect do
      Cliqr.interface do
        name nil
        handler TestCommand
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - ['name' cannot be nil]"))
  end

  it 'does not allow invalid characters in name' do
    expect do
      Cliqr.interface do
        name 'invalid-char-!'
        handler TestCommand
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [value for 'name' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-char-!\"]"))
  end

  it 'does not allow command handler to be null' do
    expect do
      Cliqr.interface do
        name 'my-command'
      end
    end.to(raise_error(Cliqr::Error::ValidationError, "invalid Cliqr interface configuration - ['handler' cannot be nil]"))
  end

  it 'only accepts command handler that extend from Cliqr::CLI::Command' do
    expect do
      Cliqr.interface do
        name 'my-command'
        handler Object
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [value 'Object' of type 'Class' for 'handler' does not extend from 'Cliqr::CLI::Command']"))
  end

  it 'expects that config options should not be nil' do
    config = Cliqr::CLI::Config.new
    config.name = 'my-command'
    config.handler = TestCommand
    config.options = nil
    config.finalize
    expect { Cliqr::CLI::Interface.build(config) }.to(
      raise_error(Cliqr::Error::ValidationError, "invalid Cliqr interface configuration - ['options' cannot be nil]"))
  end

  it 'throws multiple errors if more than one issue exists in config' do
    expect do
      Cliqr.interface do
        name 'invalid-name-!@#'
        handler Object
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [value for 'name' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-name-!@#\", " \
                       "value 'Object' of type 'Class' for 'handler' does not extend from 'Cliqr::CLI::Command']"))
  end
end
