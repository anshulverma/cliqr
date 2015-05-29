# encoding: utf-8

begin
  require 'yardstick/rake/measurement'
  require 'yardstick/rake/verify'

  # yardstick_measure task
  Yardstick::Rake::Measurement.new do |measurement|
    measurement.output = '.metrics/yard-report.txt'
  end
  CLEAN.include('.metrics')
  CLEAN.include('.yardoc')

  # verify_measurements task
  Yardstick::Rake::Verify.new do |verify|
    verify.threshold = 100
    verify.require_exact_threshold = false
  end
rescue LoadError
  # do nothing
end
