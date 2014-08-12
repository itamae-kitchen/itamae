require 'spec_helper'

module Itamae
  describe Resource do
    describe "#get_resource_class_name" do
      let(:method) { :foo_bar_baz }
      it "returns camel-cased string" do
        expect(described_class.get_resource_class_name(method)).
          to eq("FooBarBaz")
      end
    end
  end
end

