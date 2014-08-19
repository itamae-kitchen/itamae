require 'itamae'

module Itamae
  describe Resource::RemoteFile do
    let(:runner) do
      double(:runner).tap do |r|
        r.stub(:tmpdir).and_return("/tmp/itamae")
      end
    end
    let(:recipe) do
      double(:recipe).tap do |r|
        r.stub(:runner).and_return(runner)
      end
    end

    subject(:resource) do
      described_class.new(recipe, "name") do
        source "source.file"
        path "/path/to/dst"
      end
    end

    describe "#create_action" do
      it "copies a file" do
        recipe.stub(:path).and_return("/recipe_dir/recipe_file")
        expect(subject).to receive(:copy_file).with("/recipe_dir/source.file", %r{^/tmp/itamae/[\d\.]+$})
        expect(subject).to receive(:run_specinfra).with(:check_file_is_file, "/path/to/dst").and_return(true)
        expect(subject).to receive(:run_command).with("cp /path/to/dst /path/to/dst.bak")
        expect(subject).to receive(:run_command).with(%r{mv /tmp/itamae/[\d\.]+ /path/to/dst})
        subject.create_action
      end
    end
  end
end


