require 'spec_helper'

describe Itamae::Handler::Base do
  subject(:handler) { described_class.new({}) }

  context "when receiving recipe_started event" do
    it "stores the payload" do
      subject.event(:recipe_started, :payload)
      expect(subject.recipes).to eq([:payload])
    end
  end

  context "when receiving recipe_completed event" do
    before do
      subject.event(:recipe_started, :payload)
    end

    it "pops the payload" do
      subject.event(:recipe_completed, :payload)
      expect(subject.recipes).to eq([])
    end
  end

  context "when receiving recipe_failed event" do
    before do
      subject.event(:recipe_started, :payload)
    end

    it "pops the payload" do
      subject.event(:recipe_failed, :payload)
      expect(subject.recipes).to eq([])
    end
  end
end
