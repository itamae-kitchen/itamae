require 'spec_helper'
require 'itamae/handler/fluentd'

describe Itamae::Handler::Fluentd do
  subject(:handler) do
    described_class.new(options).tap do |h|
      h.fluent_logger = fluent_logger
    end
  end
  let(:options) { {'hostname' => 'me'} }
  let(:fluent_logger) { Fluent::Logger::TestLogger.new }

  describe '#event' do
    it 'posts a record to fluent logger' do
      subject.event(:type, {arg: 'value'})
      expect(fluent_logger.queue).to eq([{arg: 'value', hostname: 'me'}])
    end
  end
end
