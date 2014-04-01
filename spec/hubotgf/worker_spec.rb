require 'spec_helper'

module HubotGf
  describe Worker do

    class TestWorker
      include HubotGf::Worker
      @queue = 'default'
      self.command = /Make (.*) a (.*)/
      def perform(who, what, sender, room); "Made #{who} a #{what}, sender: #{sender}, room: #{room}" end
      def self.perform(who, what, sender); "Made #{who} a #{what} (Resque)" end
    end

    it 'finds the TestWorker and queues it' do
      HubotGf::Worker.start('Make me a pizza').should match /Made me a pizza/
    end

    it 'does nothing and returns nil when no workers handle the request' do
      HubotGf::Worker.start('Do nothing').should == nil
    end

    it 'passes the sender in only when the worker accepts it' do
      HubotGf::Worker.start('Make me a pizza', sender: 'test-jid', room: 'test-room').should == 'Made me a pizza, sender: test-jid, room: test-room'
    end

    context 'when worker doesnt care about sender/room' do
      class ApathyWorker
        include HubotGf::Worker
        self.command = /Send back (.*)/
        def perform(arg); arg end
      end

      it 'finds the ApathyWorker and queues it' do
        HubotGf::Worker.start('Send back test').should == 'test'
      end
    end

    context 'when performer is Sidekiq' do
      before do
        require 'sidekiq'
        require 'sidekiq/testing'
        TestWorker.send(:include, Sidekiq::Worker)
        HubotGf.configure { |config| config.performer = :sidekiq }
      end

      it 'queues up a Sidekiq worker' do
        Sidekiq::Testing.fake! do
          HubotGf::Worker.start('Make me a pizza')
          TestWorker.jobs.size.should == 1
        end
      end
    end

    context 'when performer is Resque' do
      before do
        require 'resque'
        Resque.inline = true
        HubotGf.configure { |config| config.performer = :resque }
      end

      it 'queues up a Resque worker' do
        expect(TestWorker).to receive(:perform) { true }
        HubotGf::Worker.start('Make me a pizza')
      end
    end

  end
end