require "faraday"
require "faraday_middleware"

module HubotGf
  class Messenger

    delegate :pm, :broadcast, to: :client

    private

      def client
        case HubotGf::Config.adapter
        when :hipchat
          HubotGf::Adapters::Hipchat.new
        end
      end

  end
end