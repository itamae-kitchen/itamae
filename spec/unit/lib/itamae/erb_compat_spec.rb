require 'spec_helper'
require 'erb'

# Issue: The ERB compatibility branch for Ruby < 2.6 is dead code.
# The code should use the keyword argument form directly.
RSpec.describe "ERB template initialization" do
  it "does not contain a compatibility branch for old Ruby" do
    source = File.read(File.expand_path("../../../../lib/itamae/resource/template.rb", __dir__))

    # The old positional-argument form should not be present
    expect(source).not_to include("ERB.new(template, nil,"),
      "Dead compatibility code for Ruby < 2.6 should be removed"
  end
end
