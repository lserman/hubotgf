module HubotGf
  module Config
    extend self

    attr_accessor :perform, :performer, :hubot_url

    def configure
      yield self
    end

    def perform
      @perform || lambda do |worker, args, metadata = {}|
        arity = worker.instance_method(:perform).arity
        args << metadata[:sender] if arity > args.length
        args << metadata[:room]   if arity > args.length

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