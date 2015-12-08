require 'spec_helper'

module Itamae
  describe Handler do
    describe ".from_type" do
      it "returns handler class" do
        expect(described_class.from_type('debug')).to eq(Handler::Debug)
      end
    end
  end
end
