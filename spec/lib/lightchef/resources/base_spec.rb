require 'lightchef'

module Lightchef
  describe Resources::Base do
    let(:commands) { double(:commands) }
    let(:backend) do
      double(:backend).tap do |b|
        b.stub(:commands).and_return(commands)
      end
    end
    let(:runner) do
      double(:runner).tap do |b|
        b.stub(:backend).and_return(backend)
      end
    end
    let(:recipe) do
      double(:recipe).tap do |r|
        r.stub(:current_runner).and_return(runner)
      end
    end
    subject(:resource) { described_class.new(recipe, "name") }

    describe "#run" do
      before do
        subject.action :action_name
      end
      it "executes <ACTION_NAME>_action method" do
        expect(subject).to receive(:action_name_action)
        subject.run
      end
    end

    describe "#fetch_option" do
      context "when the option for the key exists" do
        before do
          subject.option_key :option_value
        end
        it "returns the value" do
          expect(subject.fetch_option(:option_key)).
            to eq(:option_value)
        end
      end
      context "when the option for the key doesn't exist" do
        it "raises Resources::Error" do
          expect do
            subject.fetch_option(:invalid_option_key)
          end.to raise_error(Resources::Error)
        end
      end
    end

    describe "#run_specinfra_command" do
      it "runs specinfra's command by specinfra's backend" do
        expect(commands).to receive(:cmd).and_return("command")
        expect(backend).to receive(:run_command).with("command").
          and_return(SpecInfra::CommandResult.new(exit_status: 0))
        subject.run_specinfra_command(:cmd)
      end
      context "when the command execution failed" do
        it "raises CommandExecutionError" do
          expect(commands).to receive(:cmd).and_return("command")
          expect(backend).to receive(:run_command).with("command").
            and_return(SpecInfra::CommandResult.new(exit_status: 1))
          expect do
            subject.run_specinfra_command(:cmd)
          end.to raise_error(Resources::CommandExecutionError)
        end
      end
    end

    describe "#copy_file" do
      it "copies a file, using the backend" do
        expect(backend).to receive(:copy_file).with(:src, :dst)
        subject.copy_file(:src, :dst)
      end
    end
  end
end
