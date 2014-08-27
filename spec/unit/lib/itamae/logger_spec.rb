require 'spec_helper'

module Itamae
  describe Logger do
    let(:io) { StringIO.new }

    before do
      Logger.log_device = io
    end

    [:fatal, :error, :warn, :info, :debug].each do |level|
      describe "##{level}" do
        it "puts #{level} log" do
          Logger.public_send(level, "CONTENT")
          expect(io.string).to include('CONTENT')
        end
      end
    end
  end
end
