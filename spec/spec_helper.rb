# frozen_string_literal: true
if ENV['CI']
  # enable code climate
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.configure do |config|
    config.logger.level = Logger::WARN
  end
  CodeClimate::TestReporter.start

  # enable coveralls
  require 'coveralls'
  Coveralls.wear!
end

# enable simplecov for code coverage
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    SimpleCov.minimum_coverage 100
  end
end

require 'bundler/setup'
Bundler.setup

require 'cliqr'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
