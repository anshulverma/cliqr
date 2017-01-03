# frozen_string_literal: true
require 'argument_parser_spec_helper'

describe Cliqr::Parser do
  TEST_CLI = Cliqr.interface do
    name 'my-command'
    handler TestCommand
    arguments :disable

    option 'test-option' do
      short 't'
    end
  end
  CONFIG = TEST_CLI.config

  it 'can parse no argument command' do
    assert_results(CONFIG, [], Cliqr::Parser::ParsedInput.new(command: 'my-command', options: {}))
  end

  it 'can parse command with option using long name' do
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {
                                                    'test-option' => ['abcd']
                                                  })
    assert_results(CONFIG, %w(--test-option abcd), parsed_input)
  end

  it 'can parse multiple options' do
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {
                                                    'test-option-1' => ['abcd'],
                                                    'test-option-2' => ['xyz']
                                                  })
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand

      option 'test-option-1'
      option 'test-option-2'
    end
    assert_results(cli.config, %w(--test-option-1 abcd --test-option-2 xyz), parsed_input)
  end

  it 'can parse command with option using short name' do
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {
                                                    'test-option' => ['abcd']
                                                  })
    assert_results(CONFIG, %w(-t abcd), parsed_input)
  end

  it 'cannot parse unknown options' do
    expect { Cliqr::Parser.parse(CONFIG, %w(--unknown-option abcd)) }.to(
      raise_error(Cliqr::Error::UnknownCommandOption, 'unknown option "--unknown-option"')
    )
    expect { Cliqr::Parser.parse(CONFIG, %w(-u abcd)) }.to(
      raise_error(Cliqr::Error::UnknownCommandOption, 'unknown option "-u"')
    )
  end

  it 'cannot parse invalid options' do
    expect { Cliqr::Parser.parse(CONFIG, %w(--1)) }.to(
      raise_error(Cliqr::Error::IllegalArgumentError, 'invalid command argument "--1"')
    )
    expect { Cliqr::Parser.parse(CONFIG, %w(-$)) }.to(
      raise_error(Cliqr::Error::IllegalArgumentError, 'invalid command argument "-$"')
    )
  end

  it 'cannot parse option without value if required' do
    expect { Cliqr::Parser.parse(CONFIG, %w(--test-option)) }.to(
      raise_error(Cliqr::Error::OptionValueMissing, 'a value must be defined for argument "--test-option"')
    )
  end

  it 'cannot parse option if it has multiple values' do
    expect { Cliqr::Parser.parse(CONFIG, %w(--test-option val1 --test-option val2)) }.to(
      raise_error(Cliqr::Error::MultipleOptionValues, 'multiple values for option "--test-option"')
    )
  end

  it 'can parse command with arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      arguments :enable

      option 'test-option' do
        short 't'
      end
    end
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {},
                                                  arguments: ['value1'])
    assert_results(cli.config, ['value1'], parsed_input)
  end

  it 'can parse command with one option and one argument' do
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {
                                                    'test-option' => ['abcd']
                                                  },
                                                  arguments: ['value1'])
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      arguments :enable

      option 'test-option' do
        short 't'
      end
    end

    assert_results(cli.config, %w(-t abcd value1), parsed_input)
    assert_results(cli.config, %w(value1 -t abcd), parsed_input)
  end

  it 'can parse command with a mix of options and arguments' do
    cli = Cliqr.interface do
      name 'my-command'
      handler TestCommand
      arguments :enable

      option 'test-option-1' do
        short 't'
      end

      option 'test-option-2' do
        short 'p'
      end
    end
    config = cli.config
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  arguments: %w(value1 value2),
                                                  options: {
                                                    'test-option-1' => ['abcd'],
                                                    'test-option-2' => ['qwe']
                                                  })
    assert_results(config, %w(-t abcd -p qwe value1 value2), parsed_input)
    assert_results(config, %w(value1 -t abcd value2 -p qwe), parsed_input)
    assert_results(config, %w(-t abcd value1 -p qwe value2), parsed_input)
  end

  it 'can parse command with multiple arguments for a option' do
    cli = Cliqr.interface do
      name 'my-command'
      arguments :enable

      option 'test-option' do
        short 't'
        multi_valued true
      end

      option 'test-option-2' do
        short 'p'
        multi_valued false
      end
    end
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  arguments: [],
                                                  options: {
                                                    'test-option' => %w(v1 v2 v3),
                                                    'test-option-2' => %w(x)
                                                  })
    assert_results(cli.config, %w(--test-option v1 -t v2 --test-option v3 -p x), parsed_input)
  end

  it 'can parse command with multiple arguments for a numeric option' do
    cli = Cliqr.interface do
      name 'my-command'
      arguments :enable

      option 'test-option' do
        multi_valued true
        type :numeric
      end
    end
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {},
                                                  arguments: ['value1'])
    assert_results(cli.config, ['value1'], parsed_input)
  end

  it 'can parse command with multiple arguments for a boolean option' do
    cli = Cliqr.interface do
      name 'my-command'
      arguments :enable

      option 'test-option' do
        multi_valued true
        type :boolean
      end
    end
    parsed_input = Cliqr::Parser::ParsedInput.new(command: 'my-command',
                                                  options: {},
                                                  arguments: ['value1'])
    assert_results(cli.config, ['value1'], parsed_input)
  end
end
