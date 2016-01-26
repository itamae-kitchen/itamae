require 'spec_helper'

module Itamae
  describe Logger do
    describe "#debug" do
      context "`msg` is a String" do
        it "indents the message" do
          expect_any_instance_of(::Logger).to receive(:debug).with("  msg")
          Itamae.logger.with_indent do
            Itamae.logger.debug("msg")
          end
        end
      end

      context "`msg` is an Exception" do
        let(:msg) { ::Exception.new("error") }

        before do
          allow(msg).to receive(:backtrace) { %w!frame1 frame2! }
        end

        it "indents the error message and the backtrace" do
          expect_any_instance_of(::Logger).to receive(:debug).with(<<-MSG.rstrip)
  error (Exception)
  frame1
  frame2
          MSG
          Itamae.logger.with_indent do
            Itamae.logger.debug(msg)
          end
        end
      end

      context "`msg` is an Array" do
        it "indents the message" do
          expect_any_instance_of(::Logger).to receive(:debug).with("  []")
          Itamae.logger.with_indent do
            Itamae.logger.debug([])
          end
        end
      end
    end
  end
end
