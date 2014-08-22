require 'spec_helper'
require 'tmpdir'

module Itamae
  describe Runner do
    subject { described_class.new(double(:node)) }

    around do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          example.run
        end
      end
    end

    describe ".run" do
      let(:recipes) { %w! ./recipe1.rb ./recipe2.rb ! }
      it "runs each recipe with the runner" do
        pending "Rewrite later"
        recipes.each do |r|
          recipe = double(:recipe)
          Recipe.stub(:new).with(
            an_instance_of(Itamae::Runner),
            File.expand_path(r)
          ).and_return(recipe)
          expect(recipe).to receive(:run)
        end
        described_class.run(recipes, :local, {})
      end
    end
  end
end
