require "faraday"
require "faraday_middleware"

module HubotGf
  class Messenger

    def pm(jid, message)
      Rails.logger.info "Sending message to #{jid}"
      client.post '/hubot/pm', { replyTo: jid, message: message }
    end

    def broadcast(room, message)
      Rails.logger.info "Sending message to #{room}, message: #{message}"
      client.post '/hubot/room', { room: room, message: message }
    end

    private

      def client
        @client ||= Faraday.new(url: HubotGf::Config.hubot_url) do |http|
          http.request :json
          http.adapter :net_http
        end
      end

  end
end