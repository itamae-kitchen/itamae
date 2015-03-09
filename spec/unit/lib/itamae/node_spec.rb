require 'spec_helper'

module Itamae
  describe Node do
    describe "#reverse_merge" do
      it "merges a hash but the method receiver's value will be preferred" do
        a = described_class.new(a: :b, c: :d)
        expected = described_class.new(a: :b, c: :d, e: :f)
        expect(a.reverse_merge(a: :c, e: :f)).to eq(expected)
      end
    end

    describe Node::Validator do
      let(:node) do
        Node.new({
          profile: {
            name: "Ryota Arai",
            locations: ["Tokyo", 1234],
          },
        })
      end

      let(:schema) do
        {
          missing: String,
          profile: {
            name: Integer,
            locations: [String],
          }
        }
      end

      describe "#validate" do
        it "returns errors" do
          errors = described_class.new.validate(schema, node)
          expect(errors[0].location).to eq([:missing])
          expect(errors[0].message).to eq(["is missing"])
        end
      end
    end
  end
end
