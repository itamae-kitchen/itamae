require 'spec_helper'

describe package('dstat') do
  it { should be_installed }
end

describe package('sl') do
  it { should be_installed }
end
