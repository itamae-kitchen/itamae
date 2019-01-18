require 'spec_helper'

describe file('/tmp/remote_file') do
  it { should be_file }
  it { should be_owned_by "ordinary_san" }
  it { should be_grouped_into "ordinary_san" }
  its(:content) { should match(/Hello Itamae/) }
end

describe file('/tmp/remote_file_root') do
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "root" }
  its(:content) { should match(/Hello Itamae/) }
end

%w[/tmp/remote_file_another_ordinary /tmp/remote_file_another_ordinary_with_root].each do |path|
  describe file(path) do
    it { should be_file }
    it { should be_owned_by "itamae" }
    it { should be_grouped_into "itamae" }
    its(:content) { should match(/Hello Itamae/) }
  end
end

###

describe file('/tmp/file') do
  it { should be_file }
  it { should be_owned_by "ordinary_san" }
  it { should be_grouped_into "ordinary_san" }
  its(:content) { should match(/Hello World/) }
end

describe file('/tmp/file_root') do
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "root" }
  its(:content) { should match(/Hello World/) }
end

%w[/tmp/file_another_ordinary /tmp/file_another_ordinary_with_root].each do |path|
  describe file(path) do
    it { should be_file }
    it { should be_owned_by "itamae" }
    it { should be_grouped_into "itamae" }
    its(:content) { should match(/Hello World/) }
  end
end

###

describe file('/tmp/template') do
  it { should be_file }
  it { should be_owned_by "ordinary_san" }
  it { should be_grouped_into "ordinary_san" }
  its(:content) { should match(/Hello/) }
  its(:content) { should match(/Good bye/) }
  its(:content) { should match(/^total memory: \d+kB$/) }
  its(:content) { should match(/^uninitialized node key: $/) }
end

describe file('/tmp/template_root') do
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "root" }
  its(:content) { should match(/Hello/) }
  its(:content) { should match(/Good bye/) }
  its(:content) { should match(/^total memory: \d+kB$/) }
  its(:content) { should match(/^uninitialized node key: $/) }
end

%w[/tmp/template_another_ordinary /tmp/template_another_ordinary_with_root].each do |path|
  describe file(path) do
    it { should be_file }
    it { should be_owned_by "itamae" }
    it { should be_grouped_into "itamae" }
    its(:content) { should match(/Hello/) }
    its(:content) { should match(/Good bye/) }
    its(:content) { should match(/^total memory: \d+kB$/) }
    its(:content) { should match(/^uninitialized node key: $/) }
  end
end

###

describe file('/tmp/http_request.html') do
  it { should be_file }
  it { should be_owned_by "ordinary_san" }
  it { should be_grouped_into "ordinary_san" }
  its(:content) { should match(/"from":\s*"itamae"/) }
end

describe file('/tmp/http_request_root.html') do
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "root" }
  its(:content) { should match(/"from":\s*"itamae"/) }
end

%w[/tmp/http_request_another_ordinary.html /tmp/http_request_another_ordinary_with_root.html].each do |path|
  describe file(path) do
    it { should be_file }
    it { should be_owned_by "itamae" }
    it { should be_grouped_into "itamae" }
    its(:content) { should match(/"from":\s*"itamae"/) }
  end
end
