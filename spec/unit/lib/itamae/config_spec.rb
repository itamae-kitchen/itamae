require 'spec_helper'

module Itamae
  describe Config do
    describe '#load' do
      subject { config.load }

      let!(:config) { described_class.new(options) }

      context 'without config option' do
        let(:options) { ['-h', 'example.com'] }

        it { is_expected.to eq(options) }
      end

      context 'with config option' do
        let(:yaml) { 'port: 22' }

        before { allow(config).to receive(:open).and_return(yaml) }

        context 'when short option' do
          let(:options) { ['-h', 'example.com', '-c', 'config.yml'] }

          it { is_expected.to eq(['-h', 'example.com', '--port', '22']) }
        end

        context 'when long option' do
          let(:options) { ['-h', 'example.com', '--config', 'config.yml'] }

          it { is_expected.to eq(['-h', 'example.com', '--port', '22']) }
        end
      end
    end
  end
end
