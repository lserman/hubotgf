require 'spec_helper'

module HubotGF
  describe Worker do

    class TestWorker
      include HubotGF::Worker
      self.command = /Make (.*) a (.*)/
      def perform(who, what); "Made #{who} a #{what}" end
    end

    it 'finds the TestWorker and queues it' do
      HubotGF::Worker.start('Make me a pizza').should == 'Made me a pizza'
    end

    it 'does nothing and returns nil when no workers handle the request' do
      HubotGF::Worker.start('Do nothing').should == nil
    end

  end
end