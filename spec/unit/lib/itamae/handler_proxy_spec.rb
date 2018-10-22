require 'spec_helper'

module Itamae
  describe HandlerProxy do
    let(:handler) { instance_double(Handler::Base) }
    before { subject.register_instance(handler) }

    describe "#event" do
      context "with block" do
        context "when the block completes" do
          it "fires *_started and *_completed events" do
            expect(handler).to receive(:event).with(:name_started, :arg)
            expect(handler).to receive(:event).with(:name_completed, :arg)
            subject.event(:name, :arg) { }
          end
        end

        context "when the block fails" do
          it "fires *_started and *_failed events" do
            expect(handler).to receive(:event).with(:name_started, :arg)
            expect(handler).to receive(:event).with(:name_failed, :arg)
            expect {
              subject.event(:name, :arg) { raise "name is failed" }
            }.to raise_error "name is failed"
          end
        end
      end

      context "without block" do
        it "fires the event" do
          expect(handler).to receive(:event).with(:name, :arg)
          subject.event(:name, :arg)
        end
      end
    end
  end
end

