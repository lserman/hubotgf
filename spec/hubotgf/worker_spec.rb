require 'spec_helper'

module HubotGf
  describe Worker do

    class TestWorker
      include HubotGf::Worker
      @queue = 'default'
      listen %r[Make (.*) a (.*)] => :test!
      listen %r[Message] => :messaging
      def test!(who, what); "Made #{who} a #{what}, sender: #{@sender}, room: #{@room}" end
      def messaging; reply 'Test!' end
    end

    it 'finds the TestWorker and queues it' do
      HubotGf::Worker.start('Make me a pizza').should match 'Made me a pizza'
    end

    it 'does nothing and returns nil when no workers handle the request' do
      HubotGf::Worker.start('Do nothing').should == nil
    end

    it 'has @sender and @room available' do
      HubotGf::Worker.start('Make me a pizza', 'sender-jid', 'test-room').should == 'Made me a pizza, sender: sender-jid, room: test-room'
    end

    describe '#reply' do
      before do
        stub_request(:post, %r[hubot/pm]).to_return status: 200
        stub_request(:post, %r[hubot/room]).to_return status: 200
      end

      it 'sends back to the user if message was a PM' do
        HubotGf::Worker.start('Message', 'sender-jid', 'sender-jid')
        WebMock.should have_requested :post, %r[hubot/pm]
      end

      it 'sends back to the room if the message was in a room' do
        HubotGf::Worker.start('Message', 'sender-jid', 'room-id')
        WebMock.should have_requested :post, %r[hubot/room]
      end
    end

    context 'when worker has multiple commands' do
      class BusyWorker
        include HubotGf::Worker
        listen %r[First: (.*)] => :first
        listen %r[Second: (.*)] => :second
        def first(arg); "1: #{arg}"; end
        def second(arg); "2: #{arg}"; end
      end

      it 'can call both commands' do
        HubotGf::Config.performer = nil
        HubotGf::Worker.start('First: TESTA').should == '1: TESTA'
        HubotGf::Worker.start('Second: TESTB').should == '2: TESTB'
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
        expect_any_instance_of(TestWorker).to receive(:test!) { true }
        HubotGf::Worker.start('Make me a pizza')
      end
    end

  end
end