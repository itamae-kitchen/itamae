require 'spec_helper'

# Issue 49: Logger.const_get with user-controlled log_level could
# resolve unintended constants.
RSpec.describe "Log level validation" do
  describe "Itamae::Logger::LEVELS" do
    it "lists known log level names" do
      expect(Itamae::Logger::LEVELS).to eq(%w[DEBUG INFO WARN ERROR FATAL UNKNOWN])
    end
  end

  describe "#acceptable_level?" do
    it "accepts valid log levels" do
      %w[debug INFO Warn Error FATAL unknown].each do |level|
        expect(Itamae.logger.acceptable_level?(level)).to be(true), "expected '#{level}' to be acceptable"
      end
    end

    it "rejects invalid log levels" do
      %w[FOO bar VERBOSE trace].each do |level|
        expect(Itamae.logger.acceptable_level?(level)).to be(false), "expected '#{level}' to be rejected"
      end
    end
  end
end
