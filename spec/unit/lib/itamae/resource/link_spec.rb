require 'itamae'

module Itamae
  describe Resource::Link do
    let(:recipe) { double(:recipe) }

    subject(:resource) do
      described_class.new(recipe, "name") do
        to "/path/to/target"
      end
    end

    describe "#create_action" do
      it "runs install command of specinfra" do
        subject.link :link_name
        expect(subject).to receive(:run_specinfra).with(:check_file_is_linked_to, :link_name, "/path/to/target").and_return(false)
        expect(subject).to receive(:run_specinfra).with(:link_file_to, :link_name, "/path/to/target")
        subject.create_action
      end
    end
  end
end


