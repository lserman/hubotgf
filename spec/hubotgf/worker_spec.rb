require 'spec_helper'

module HubotGF
  describe Worker do

    class TestWorker
      include HubotGF::Worker
      @queue = 'default'
      self.command = /Make (.*) a (.*)/
      def perform(who, what); "Made #{who} a #{what}" end
      def self.perform(who, what); "Made #{who} a #{what} (Resque)" end
    end

    it 'finds the TestWorker and queues it' do
      HubotGF::Worker.start('Make me a pizza').should == 'Made me a pizza'
    end

    it 'does nothing and returns nil when no workers handle the request' do
      HubotGF::Worker.start('Do nothing').should == nil
    end

    context 'when performer is Sidekiq' do
      before do
        require 'sidekiq'
        require 'sidekiq/testing'
        TestWorker.send(:include, Sidekiq::Worker)
        HubotGF.configure { |config| config.performer = :sidekiq }
      end

      it 'queues up a Sidekiq worker' do
        Sidekiq::Testing.fake! do
          HubotGF::Worker.start('Make me a pizza')
          TestWorker.jobs.size.should == 1
        end
      end
    end

    context 'when performer is Resque' do
      before do
        require 'resque'
        Resque.inline = true
        HubotGF.configure { |config| config.performer = :resque }
      end

      it 'queues up a Resque worker' do
        expect(TestWorker).to receive(:perform) { true }
        HubotGF::Worker.start('Make me a pizza')
      end
    end

  end
end