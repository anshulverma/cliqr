# encoding: utf-8

require 'fixtures/test_command'

describe Cliqr::CLI::OptionConfig do
  it 'does not allow multiple options with same long name' do
    expect do
      Cliqr.interface do
        name 'my-command'
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
        name 'my-command'
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
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option '' do
          short 'p'
        end
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [options[1] - 'name' cannot be empty]"))
  end

  it 'does not allow option with empty short name' do
    expect do
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          short ''
        end
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [options[1] - 'short' cannot be empty]"))
  end

  it 'does not allow option with nil long name' do
    expect do
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option nil
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [options[1] - 'name' cannot be nil]"))
  end

  it 'does not allow option with nil long name for second option' do
    expect do
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1'
        option ''
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [options[2] - 'name' cannot be empty]"))
  end

  it 'does not allow multiple characters in short name' do
    expect do
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          short 'p1'
        end
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [options[1] - value for 'short' must match /^[a-z0-9A-Z]$/; actual: \"p1\"]"))
  end

  it 'does not allow invalid type values' do
    expect do
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          type :random
        end
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [options[1] - invalid type 'random']"))
  end

  it 'does not allow empty type values' do
    expect do
      Cliqr.interface do
        name 'my-command'
        description 'a command used to test cliqr'
        handler TestCommand

        option 'option-1' do
          type ''
        end
      end
    end.to(raise_error(Cliqr::Error::ValidationError,
                       "invalid Cliqr interface configuration - [options[1] - invalid type '']"))
  end
end
