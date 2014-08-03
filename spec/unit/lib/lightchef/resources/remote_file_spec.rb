require 'lightchef'

module Lightchef
  describe Resources::RemoteFile do
    let(:recipe) { double(:recipe) }
    subject(:resource) do
      described_class.new(recipe, "name") do
        source "source.file"
        path "/path/to/dst"
      end
    end

    describe "#create_action" do
      it "copies a file" do
        recipe.stub(:path).and_return("/recipe_dir/recipe_file")
        expect(subject).to receive(:copy_file).with("/recipe_dir/source.file", "/path/to/dst")
        subject.create_action
      end
    end
  end
end


