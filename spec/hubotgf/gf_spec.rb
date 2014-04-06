require 'spec_helper'

module HubotGF
  describe GF do

    before do
      stub_request(:post, "http://hubot-gf-test.com/hubot/pm").to_return status: 200, body: "", headers: {}
      stub_request(:post, "http://hubot-gf-test.com/hubot/room").to_return status: 200, body: "", headers: {}
      HubotGF.configure { |config| config.hubot_url = 'http://hubot-gf-test.com' }
    end

    describe '#pm' do
      it 'sends a PM to a Hubot JID' do
        HubotGF::GF.new.pm('test-jid', 'Message')
        WebMock.should have_requested(:post, 'http://hubot-gf-test.com/hubot/pm').with(body: '{"replyTo":"test-jid","message":"Message"}')
      end
    end

    describe '#room' do
      it 'sends a PM to a Hubot room' do
        HubotGf::Messenger.new.broadcast('test-room', 'Message')
        WebMock.should have_requested(:post, 'http://hubot-gf-test.com/hubot/room').with(body: '{"room":"test-room","message":"Message"}')
      end
    end

  end
end