# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::Config do
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

  it 'does not allow command handler to be null if no action present' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        help :disable
      end
    end
    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               'invalid Cliqr interface configuration - [' \
                                                 "invalid value for handler; fix one of - ['handler' cannot be nil]]"))
  end

  it 'only accepts command handler that extend from Cliqr::Command::BaseCommand' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        handler Object
      end
    end

    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               'invalid Cliqr interface configuration - [' \
                                                 'invalid value for handler; fix one of - [' \
                                                   "handler of type 'Object' does not extend from 'Cliqr::Command::BaseCommand', " \
                                                   "handler should be a 'Proc' not 'Object']]"))
  end

  it 'expects that config options should not be nil' do
    config = Cliqr::Config::CommandConfig.new
    config.name = 'my-command'
    config.handler = TestCommand
    config.options = nil
    config.finalize
    expect { Cliqr::Interface.build(config) }.to(
      raise_error(Cliqr::Error::ValidationError, "invalid Cliqr interface configuration - ['options' cannot be nil]"))
  end

  it 'throws multiple errors if more than one issue exists in config' do
    def define_interface
      Cliqr.interface do
        name 'invalid-name-!@#'
        handler Object
      end
    end

    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               'invalid Cliqr interface configuration - [' \
                                                 "value for 'name' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-name-!@#\", " \
                                                 'invalid value for handler; fix one of - [' \
                                                   "handler of type 'Object' does not extend from 'Cliqr::Command::BaseCommand', " \
                                                   "handler should be a 'Proc' not 'Object']]"))
  end

  it 'expects that shell be non-nil for command config' do
    config = Cliqr::Config::CommandConfig.new
    config.name = 'my-command'
    config.handler = TestCommand
    config.shell = nil
    config.finalize
    expect { Cliqr::Interface.build(config) }.to(
      raise_error(NoMethodError, "undefined method `valid?' for nil:NilClass"))
  end

  it 'validates shell enable and prompt setting' do
    def define_interface
      Cliqr.interface do
        name 'test-command'
        handler TestCommand
        shell Object do
          prompt Object
        end
      end
    end
    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               'invalid Cliqr interface configuration - [' \
                                                 "shell - invalid type 'Object', " \
                                                 'shell - invalid value for prompt; fix one of - [' \
                                                   "prompt of type 'Class' does not extend from 'Cliqr::Command::ShellPrompt', " \
                                                   "prompt should be a 'Proc' not 'Class', prompt should be a 'String' not 'Class']]"))
  end
end
