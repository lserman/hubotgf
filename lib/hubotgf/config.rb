module HubotGf
  module Config
    extend self

    attr_accessor :perform, :performer, :hubot_url

    def configure
      yield self
    end

    def perform
      @perform || lambda do |worker, args, metadata = {}|
        case performer
        when :sidekiq
          Sidekiq::Client.enqueue(worker, *args, metadata)
        when :resque
          Resque.enqueue(worker, *args, metadata)
        else
          worker.new.perform(*args, metadata)
        end
      end
    end

  end
end