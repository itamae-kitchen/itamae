require 'lightchef'

module Lightchef
  describe Resources::File do
    let(:recipe) { double(:recipe) }
    subject(:resource) { described_class.new(recipe) }

    describe "#create_action" do
      it "copies a file" do
        recipe.stub(:path).and_return("/recipe_dir/recipe_file")
        subject.source "source.file"
        subject.path "/path/to/dst"
        expect(subject).to receive(:copy_file).with("/recipe_dir/source.file", "/path/to/dst")
        subject.create_action
      end
    end
  end
end


