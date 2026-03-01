require 'spec_helper'

# Issue: The tmpdir should not be world-writable (777).
# Other users could tamper with temp files during execution.
RSpec.describe "Runner tmpdir permissions" do
  it "does not use world-writable mode 777" do
    source = File.read(File.expand_path("../../../../lib/itamae/runner.rb", __dir__))

    chmod_lines = source.lines.select { |l| l =~ /chmod/ && l =~ /tmpdir/ }
    modes = chmod_lines.map { |l| l[/chmod.*?["']?(\d{3,4})["']?/, 1] }.compact

    modes.each do |mode|
      expect(mode).not_to eq("777"), "tmpdir should not use mode 777 (world-writable)"
    end
  end
end
