require 'spec_helper'

describe package('dstat') do
  it { should be_installed }
end
