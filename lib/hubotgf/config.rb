module HubotGf
  module Config
    extend self

    attr_accessor :perform, :performer, :hubot_url

    def configure
      yield self
    end

    def perform
      @perform || lambda do |worker, args|
        case performer
        when :sidekiq
          Sidekiq::Client.enqueue(worker, *args)
        when :resque
          Resque.enqueue(worker, *args)
        else
          worker.new.perform(*args)
        end
      end
    end

  end
end