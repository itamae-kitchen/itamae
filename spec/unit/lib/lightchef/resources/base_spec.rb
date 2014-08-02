require 'lightchef'

class DefineOptionTestResource < Lightchef::Resources::Base
  define_option :action, default: :create
  define_option :default_option, default: :something
  define_option :required_option, required: true
  define_option :typed_option, type: Numeric
  define_option :default_name_option, default_name: true
end

describe DefineOptionTestResource do
  describe "define_option" do
    describe "default" do
      subject do
        described_class.new(double(:recipe), 'resource name') do
          required_option :required_value
        end
      end
      it "returns the default value" do
        expect(subject.options[:default_option]).to eq(:something)
      end
    end

    describe "required" do
      subject do
        described_class.new(double(:recipe), 'resource name') do
          #required_option :required_value
        end
      end
      context "without setting required option" do
        it "raises an error" do
          expect do
            subject
          end.to raise_error(Lightchef::Resources::OptionMissingError)
        end
      end
    end

    describe "type" do
      context "with correct type value" do
        subject do
          described_class.new(double(:recipe), 'resource name') do
            required_option :required_value
            typed_option 10
          end
        end
        it "returns the value" do
          expect(subject.options[:typed_option]).to eq(10)
        end
      end

      context "with incorrect type value" do
        subject do
          described_class.new(double(:recipe), 'resource name') do
            required_option :required_value
            typed_option "string"
          end
        end
        it "raises an error" do
          expect do
            subject
          end.to raise_error(Lightchef::Resources::InvalidTypeError)
        end
      end
    end

    describe "default_name" do
      context "without setting the value" do
        subject do
          described_class.new(double(:recipe), 'resource name') do
            required_option :required_value
          end
        end
        it "returns the resource name" do
          expect(subject.options[:default_name_option]).
            to eq("resource name")
        end
      end
    end
  end
end

class TestResource < Lightchef::Resources::Base
  define_option :action, default: :create
  define_option :option_key, required: false
end

describe TestResource do
  let(:commands) { double(:commands) }
  let(:runner) do
    double(:runner)
  end
  let(:recipe) do
    double(:recipe).tap do |r|
      r.stub(:runner).and_return(runner)
    end
  end

  subject(:resource) { described_class.new(recipe, "name") }

  before do
    Lightchef.backend = double(:backend).tap do |b|
      b.stub(:commands).and_return(commands)
    end
  end

  describe "#run" do
    before do
      subject.action :action_name
    end
    it "executes <ACTION_NAME>_action method" do
      expect(subject).to receive(:action_name_action)
      subject.run
    end
  end

  describe "#run_specinfra" do
    it "runs specinfra's command by specinfra's backend" do
      expect(commands).to receive(:cmd).and_return("command")
      expect(Lightchef.backend).to receive(:run_command).with("command").
        and_return(Specinfra::CommandResult.new(exit_status: 0))
      subject.send(:run_specinfra, :cmd)
    end
    context "when the command execution failed" do
      it "raises CommandExecutionError" do
        expect(commands).to receive(:cmd).and_return("command")
        expect(Lightchef.backend).to receive(:run_command).with("command").
          and_return(Specinfra::CommandResult.new(exit_status: 1))
        expect do
          subject.send(:run_specinfra, :cmd)
        end.to raise_error(Lightchef::Resources::CommandExecutionError)
      end
    end
  end

  describe "#copy_file" do
    it "copies a file, using the backend" do
      expect(Lightchef.backend).to receive(:copy_file).with(:src, :dst)
      subject.send(:copy_file, :src, :dst)
    end
  end
end
