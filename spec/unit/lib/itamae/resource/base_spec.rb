require 'itamae'

class DefineAttributeTestResource < Itamae::Resource::Base
  define_attribute :action, default: :create
  define_attribute :default_attribute, default: :something
  define_attribute :required_attribute, required: true
  define_attribute :typed_attribute, type: Numeric
  define_attribute :default_name_attribute, default_name: true
end

describe DefineAttributeTestResource do
  describe "define_attribute" do
    describe "default" do
      subject do
        described_class.new(double(:recipe), 'resource name') do
          required_attribute :required_value
        end
      end
      it "returns the default value" do
        expect(subject.attributes[:default_attribute]).to eq(:something)
      end
    end

    describe "falsey" do
      subject do
        described_class.new(double(:recipe), 'resource name') do
          required_attribute :required_value
          default_attribute nil
        end
      end
      it "returns the default value" do
        expect(subject.attributes[:default_attribute]).to eq(nil)
      end
    end

    describe "required" do
      subject do
        described_class.new(double(:recipe), 'resource name') do
          #required_attribute :required_value
        end
      end
      context "without setting required attribute" do
        it "raises an error" do
          expect do
            subject
          end.to raise_error(Itamae::Resource::AttributeMissingError)
        end
      end
    end

    describe "type" do
      context "with correct type value" do
        subject do
          described_class.new(double(:recipe), 'resource name') do
            required_attribute :required_value
            typed_attribute 10
          end
        end
        it "returns the value" do
          expect(subject.attributes[:typed_attribute]).to eq(10)
        end
      end

      context "with incorrect type value" do
        subject do
          described_class.new(double(:recipe), 'resource name') do
            required_attribute :required_value
            typed_attribute "string"
          end
        end
        it "raises an error" do
          expect do
            subject
          end.to raise_error(Itamae::Resource::InvalidTypeError)
        end
      end
    end

    describe "default_name" do
      context "without setting the value" do
        subject do
          described_class.new(double(:recipe), 'resource name') do
            required_attribute :required_value
          end
        end
        it "returns the resource name" do
          expect(subject.attributes[:default_name_attribute]).
            to eq("resource name")
        end
      end
    end
  end
end

class TestResource < Itamae::Resource::Base
  define_attribute :action, default: :create
  define_attribute :attribute_key, required: false
end

describe TestResource do
  subject(:resource) { described_class.new(recipe, "name") }

  let(:commands) { double(:commands) }
  let(:runner) do
    double(:runner)
  end
  let(:recipe) do
    double(:recipe).tap do |r|
      r.stub(:runner).and_return(runner)
    end
  end

  describe "#run" do
    before do
      subject.attributes.action = :name
    end
    it "executes <ACTION_NAME>_action method" do
      expect(subject).to receive(:action_name)
      subject.run
    end
  end
end
