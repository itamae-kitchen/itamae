require 'itamae'

module Itamae
  describe Resources::Package do
    let(:recipe) { double(:recipe) }
    subject(:resource) { described_class.new(recipe, "name") }

    describe "#install_action" do
      it "runs install command of specinfra" do
        subject.name :package_name
        expect(subject).to receive(:run_specinfra).with(:install_package, :package_name)
        subject.install_action
      end
    end
  end
end


