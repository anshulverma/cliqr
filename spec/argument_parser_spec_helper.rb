# frozen_string_literal: true
require 'spec_helper'

require 'cliqr/parser/argument_parser'
require 'cliqr/parser/parsed_input'

require 'fixtures/test_command'

def assert_results(config, args, expected_result, expected_config = nil)
  expected_config ||= config
  action_config, actual_parsed_input = Cliqr::Parser.parse(config, args)
  expect(actual_parsed_input).to(match(expected_result))
  expect(action_config).to eq(expected_config)
end
