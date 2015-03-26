require 'spec_helper'

module Itamae
  describe Resource do
    describe ".parse_description" do
      context "with valid description" do
        it "returns type and name" do
          expect(described_class.parse_description("this-is_type[this-is_name]")).
            to eq(["this-is_type", "this-is_name"])
        end
      end

      context "with invalid description" do
        it "raises an error" do
          expect do
            described_class.parse_description("[this-is_type][this-is_name]")
          end.to raise_error(Itamae::Resource::ParseError)
        end
      end
    end
  end
end

