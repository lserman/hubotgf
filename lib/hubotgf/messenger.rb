require "faraday"
require "faraday_middleware"

module HubotGf
  class Messenger

    def pm(jid, message)
      Rails.logger.info "Sending message to #{jid}"
      hubot.post '/hubot/pm', { replyTo: jid, message: message }
    end

    def broadcast(room, message)
      Rails.logger.info "Sending message to #{room}, message: #{message}"
      hubot.post '/hubot/room', { room: room, message: message }
    end

    private
      def hubot
        @client ||= Faraday.new(url: HubotGf::Config.hubot_url) do |http|
          http.request :json
          http.adapter :net_http
        end
      end
  end
end
