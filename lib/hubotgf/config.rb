module HubotGF
  module Config
    extend self

    attr_accessor :perform, :performer

    def configure
      yield self
    end

    # Sidekiq::Client.enqueue(worker, *args)
    def perform
      @perform || lambda do |worker, args|
        case performer
        when :sidekiq
          Sidekiq::Client.enqueue(worker, *args)
        when :resque
          Resque.enqueue(worker, *args)
        else # inline
          worker.new.perform(*args)
        end
      end
    end

  end
end