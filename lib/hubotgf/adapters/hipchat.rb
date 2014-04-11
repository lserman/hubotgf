require 'hipchat'

module HubotGf
  module Adapters
    class Hipchat

      def pm(jid, message)
        Rails.logger.info "Sending message to #{jid}"
        client.user(jid).send(message)
      end

      def broadcast(room, message)
        Rails.logger.info "Sending message to #{room}, message: #{message}"
        client[room].send 'HubotGf', message, color: 'gray'
      end

      private

        def client
          @client ||= ::HipChat::Client.new(HubotGf::Config.hipchat_token, api_version: 'v2')
        end

    end
  end
end