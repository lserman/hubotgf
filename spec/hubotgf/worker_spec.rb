require 'spec_helper'

module HubotGf
  describe Worker do

    class TestWorker
      include HubotGf::Worker
      @queue = 'default'
      listen %r[Make (.*) a (.*)] => :test!
      def test!(who, what); "Made #{who} a #{what}, sender: #{@sender}, room: #{@room}" end
    end

    it 'finds the TestWorker and queues it' do
      HubotGf::Worker.start('Make me a pizza').should == 'Made me a pizza'
    end

    it 'does nothing and returns nil when no workers handle the request' do
      HubotGf::Worker.start('Do nothing').should == nil
    end

    it 'has @sender and @room available' do
      HubotGf::Worker.start('Make me a pizza', 'sender-jid', 'test-room').should == 'Made me a pizza, sender: sender-jid, room: test-room'
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
        expect_any_instance_of(TestWorker).to receive(:test!) { true }
        HubotGf::Worker.start('Make me a pizza')
      end
    end

  end
end