# encoding: utf-8

require 'spec_helper'

require 'fixtures/test_command'

describe Cliqr::Config do
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

  it 'does not allow command handler to be null if help is disabled and action present' do
    def define_interface
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        action 'my-action' do
          help :disable
        end
      end
    end
    expect { define_interface }.to(raise_error(Cliqr::Error::ValidationError,
                                               'invalid Cliqr interface configuration - [' \
                                                 "action \"my-action\" - invalid value for handler; fix one of - ['handler' cannot be nil]]"))
  end

  it 'only accepts command handler that extend from Cliqr::Command::BaseCommand' do
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
                                               'invalid Cliqr interface configuration - [' \
                                                 "action \"my-action\" - invalid value for handler; fix one of - [" \
                                                   "handler of type 'Object' does not extend from 'Cliqr::Command::BaseCommand', " \
                                                   "handler should be a 'Proc' not 'Object']]"))
  end

  it 'throws multiple errors if more than one issue exists in config' do
    def define_interface
      Cliqr.interface do
        name 'invalid-name-!@#'
        handler Object

        action 'my-action' do
          handler Object

          action nil do
            help :disable
          end

          action 'bla' do
            help :disable
          end
        end
      end
    end
    expect { define_interface }.to(
      raise_error(Cliqr::Error::ValidationError,
                  'invalid Cliqr interface configuration - [' \
                    "value for 'name' must match /^[a-zA-Z0-9_\\-]+$/; actual: \"invalid-name-!@#\", " \
                    'invalid value for handler; fix one of - [' \
                      "handler of type 'Object' does not extend from 'Cliqr::Command::BaseCommand', " \
                      "handler should be a 'Proc' not 'Object'], " \
                    "action \"my-action\" - invalid value for handler; fix one of - [" \
                      "handler of type 'Object' does not extend from 'Cliqr::Command::BaseCommand', " \
                      "handler should be a 'Proc' not 'Object'], " \
                    "action \"my-action\" - actions[1] - 'name' cannot be nil, " \
                    "action \"my-action\" - actions[1] - invalid value for handler; fix one of - ['handler' cannot be nil], " \
                    "action \"my-action\" - action \"bla\" - invalid value for handler; fix one of - ['handler' cannot be nil]]"))
  end
end
