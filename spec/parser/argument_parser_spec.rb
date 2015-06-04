# encoding: utf-8

require 'spec_helper'

require 'cliqr/parser/argument_parser'
require 'cliqr/parser/parsed_input'

require 'fixtures/test_command'
require 'fixtures/option_reader_command'

describe Cliqr::Parser do
  TEST_CLI = Cliqr.interface do
    basename 'my-command'
    handler TestCommand

    option 'test-option' do
      short 't'
    end
  end
  CONFIG = TEST_CLI.config
  PARSER = Cliqr::Parser

  it 'can parse no argument command' do
    expect(PARSER.parse(CONFIG, [])).to eq(Cliqr::Parser::ParsedInput.new(:command => 'my-command', :options => []))
  end

  it 'can parse command with option using long name' do
    parsed_input = Cliqr::Parser::ParsedInput.new(:command => 'my-command',
                                                  :options => [
                                                    {
                                                        :name => 'test-option',
                                                        :value => 'abcd'
                                                    }
                                                  ])
    expect(PARSER.parse(CONFIG, %w(--test-option abcd))).to eq(parsed_input)
  end

  it 'can parse multiple options' do
    parsed_input = Cliqr::Parser::ParsedInput.new(:command => 'my-command',
                                                  :options => [
                                                    {
                                                        :name => 'test-option-1',
                                                        :value => 'abcd'
                                                    },
                                                    {
                                                        :name => 'test-option-2',
                                                        :value => 'xyz'
                                                    }
                                                  ])
    cli = Cliqr.interface do
      basename 'my-command'
      handler TestCommand

      option 'test-option-1'
      option 'test-option-2'
    end
    expect(Cliqr::Parser.parse(cli.config, %w(--test-option-1 abcd --test-option-2 xyz))).to eq(parsed_input)
  end

  it 'can parse command with option using short name' do
    parsed_input = Cliqr::Parser::ParsedInput.new(:command => 'my-command',
                                                  :options => [
                                                    {
                                                        :name => 'test-option',
                                                        :value => 'abcd'
                                                    }
                                                  ])
    expect(PARSER.parse(CONFIG, %w(-t abcd))).to eq(parsed_input)
  end

  it 'cannot parse unknown options' do
    expect { PARSER.parse(CONFIG, %w(--unknown-option abcd)) }.to(
      raise_error(Cliqr::Error::UnknownCommandOption, 'unknown option "--unknown-option"'))
    expect { PARSER.parse(CONFIG, %w(-u abcd)) }.to(
      raise_error(Cliqr::Error::UnknownCommandOption, 'unknown option "-u"'))
  end

  it 'cannot parse invalid options' do
    expect { PARSER.parse(CONFIG, %w(--1)) }.to(
      raise_error(Cliqr::Error::InvalidArgumentError, 'invalid command argument "--1"'))
    expect { PARSER.parse(CONFIG, %w(-$)) }.to(
      raise_error(Cliqr::Error::InvalidArgumentError, 'invalid command argument "-$"'))
  end

  it 'cannot parse option without value if required' do
    expect { PARSER.parse(CONFIG, %w(--test-option)) }.to(
      raise_error(Cliqr::Error::OptionValueMissing, 'a value must be defined for option "--test-option"'))
  end

  it 'cannot parse option if it has multiple values' do
    expect { PARSER.parse(CONFIG, %w(--test-option val1 --test-option val2)) }.to(
      raise_error(Cliqr::Error::MultipleOptionValues, 'multiple values for option "--test-option"'))
  end
end
