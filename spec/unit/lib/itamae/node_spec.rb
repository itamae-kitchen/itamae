require 'spec_helper'

module Itamae
  describe Node do
    let(:backend) { nil }
    describe "#reverse_merge" do
      it "merges a hash but the method receiver's value will be preferred" do
        a = described_class.new({a: :b, c: :d}, backend)
        expected = described_class.new({a: :b, c: :d, e: :f}, backend)
        expect(a.reverse_merge(a: :c, e: :f).mash).to eq(expected.mash)
      end
    end
  end
end
