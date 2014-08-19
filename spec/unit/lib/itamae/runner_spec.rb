require 'spec_helper'
require 'tmpdir'

module Itamae
  describe Runner do
    subject { described_class.new(double(:node)) }

    let(:commands) { double(:commands) }

    before do
      Itamae.backend = double(:backend).tap do |b|
        b.stub(:commands).and_return(commands)
        b.stub(:run_command).
          with('mkdir -p /tmp/itamae_tmp && chmod 777 /tmp/itamae_tmp').
          and_return(Specinfra::CommandResult.new(exit_status: 0))
      end
    end

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
        recipes.each do |r|
          recipe = double(:recipe)
          Recipe.stub(:new).with(
            an_instance_of(Itamae::Runner),
            File.expand_path(r)
          ).and_return(recipe)
          expect(recipe).to receive(:run)
        end
        described_class.run(recipes, :exec, {})
      end
    end

    describe "#run_specinfra" do
      it "runs specinfra's command by specinfra's backend" do
        expect(Specinfra.command).to receive(:get).with(:cmd).and_return("command")
        expect(Itamae.backend).to receive(:run_command).with("command").
          and_return(Specinfra::CommandResult.new(exit_status: 0))
        subject.send(:run_specinfra, :cmd)
      end
      context "when the command execution failed" do
        it "raises CommandExecutionError" do
          expect(Specinfra.command).to receive(:get).with(:cmd).and_return("command")
          expect(Itamae.backend).to receive(:run_command).with("command").
            and_return(Specinfra::CommandResult.new(exit_status: 1))
          expect do
            subject.send(:run_specinfra, :cmd)
          end.to raise_error(Itamae::Runner::CommandExecutionError)
        end
      end
    end
  end
end
