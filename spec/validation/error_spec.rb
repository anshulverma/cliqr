# encoding: utf-8

require 'spec_helper'

describe Cliqr::Error do
  it 'makes use of to_s to print the error message' do
    expected_error_message = <<-EOS
something went wrong

Cause: NoMethodError - undefined method `non_existent' for {}:Hash
    EOS
    begin
      begin
        {}.non_existent
      rescue StandardError => e
        raise Cliqr::Error::CommandRuntimeException.new('something went wrong', e)
      end
    rescue Cliqr::Error::CliqrError => e
      expect(e.to_s).to eq(expected_error_message)
    end
  end
end
