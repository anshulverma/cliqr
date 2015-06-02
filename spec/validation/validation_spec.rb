# encoding: utf-8

require 'spec_helper'

describe Cliqr::Validation do
  it 'does not know how to validate unknown types' do
    expect do
      Cliqr::Validation::ValidatorFactory.get(:bla, {}).validate(nil, nil, nil)
    end.to raise_error(Cliqr::Error::UnknownValidatorType, "unknown validation type: 'bla'")
  end
end
