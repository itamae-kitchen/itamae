require 'spec_helper'

# Issue: Resource error classes should inherit from Resource::Error,
# so rescue Resource::Error catches all resource-related errors.
RSpec.describe "Resource error class hierarchy" do
  it "AttributeMissingError inherits from Resource::Error" do
    expect(Itamae::Resource::AttributeMissingError).to be < Itamae::Resource::Error
  end

  it "InvalidTypeError inherits from Resource::Error" do
    expect(Itamae::Resource::InvalidTypeError).to be < Itamae::Resource::Error
  end

  it "ParseError inherits from Resource::Error" do
    expect(Itamae::Resource::ParseError).to be < Itamae::Resource::Error
  end

  it "rescue Resource::Error catches AttributeMissingError" do
    caught = false
    begin
      raise Itamae::Resource::AttributeMissingError, "test"
    rescue Itamae::Resource::Error
      caught = true
    end
    expect(caught).to eq(true),
      "rescue Resource::Error should catch AttributeMissingError"
  end
end
