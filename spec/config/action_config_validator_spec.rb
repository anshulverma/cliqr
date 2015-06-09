# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::CLI::Config do
  it 'does not allow multiple actions with same name' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        action 'my-action' do
          handler TestCommand
        end

        action 'my-action' do
          handler TestCommand
        end
      end
    end
    expect { define_interface }.to(
      raise_error(Cliqr::Error::DuplicateActions, 'multiple actions named "my-action"'))
  end

  it 'does not allow empty name' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        action '' do
          handler TestCommand
        end
      end
    end
    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               "invalid Cliqr interface configuration - [actions[1] - 'name' cannot be empty]"))
  end

  it 'does not allow nil name' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        action nil do
          handler TestCommand
        end
      end
    end
    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               "invalid Cliqr interface configuration - [actions[1] - 'name' cannot be nil]"))
  end

  it 'does not allow invalid characters in name' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        action 'invalid-char-!' do
          handler TestCommand
        end
      end
    end
    expect { define_interface }.to(
      raise_error(Cliqr::Error::ValidationError,
                  "invalid Cliqr interface configuration - [action \"invalid-char-!\" - value for 'name' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-char-!\"]"))
  end

  it 'does not allow command handler to be null' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        action 'my-action'
      end
    end
    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               "invalid Cliqr interface configuration - [action \"my-action\" - 'handler' cannot be nil]"))
  end

  it 'only accepts command handler that extend from Cliqr::CLI::Command' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        action 'my-action' do
          handler Object
        end
      end
    end
    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               'invalid Cliqr interface configuration - ' \
                                               "[action \"my-action\" - value 'Object' of type 'Class' for 'handler' does not extend from 'Cliqr::CLI::Command']"))
  end

  it 'throws multiple errors if more than one issue exists in config' do
    def define_interface
      Cliqr.interface do
        name 'invalid-name-!@#'
        handler Object

        action 'my-action' do
          handler Object

          action nil

          action 'bla'
        end
      end
    end
    expect { define_interface }.to(
      raise_error(Cliqr::Error::ValidationError,
                  'invalid Cliqr interface configuration - [' \
                    "value for 'name' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-name-!@#\", " \
                    "value 'Object' of type 'Class' for 'handler' does not extend from 'Cliqr::CLI::Command', " \
                    "action \"my-action\" - value 'Object' of type 'Class' for 'handler' does not extend from 'Cliqr::CLI::Command', " \
                    "action \"my-action\" - actions[1] - 'name' cannot be nil, " \
                    "action \"my-action\" - actions[1] - 'handler' cannot be nil, " \
                    "action \"my-action\" - action \"bla\" - 'handler' cannot be nil]"))
  end
end
