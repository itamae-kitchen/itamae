require 'spec_helper'

module Lightchef
  describe Runner do
    describe ".run" do
      it "loads and executes recipes" do
        recipe_files = %w! a b !
        recipe_files.each do |path|
          recipe = double(:recipe).tap do |r|
            expect(r).to receive(:run)
          end
          expect(Recipe).to receive(:new).
            with(File.expand_path(path), anything).
            and_return(recipe)
        end

        described_class.run({recipe_files: recipe_files})
      end
    end
  end
end
