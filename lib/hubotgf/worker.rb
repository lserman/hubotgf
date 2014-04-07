module HubotGf
  module Worker

    def self.included(base)
      @workers ||= []
      @workers << base
      base.extend(ClassMethods)
      delegate :method, :command, to: :class
    end

    def self.start(command, sender = nil, room = nil)
      worker = @workers.find { |w| w.commands.include? command }
      if worker
        arguments = worker.commands.match(command).captures
        arguments = arguments.unshift(sender, room)
        HubotGf::Config.perform.(worker, arguments)
      end
    end

    # Sidekiq entry
    def perform(*args)
      @sender, @room = args.shift, args.shift
      send method, *args
    end

    def reply(message)
      HubotGf::Messenger.new.pm(@sender, message)
    end

    def rebroadcast(message)
      HubotGf::Messenger.new.broadcast(@room, message)
    end

    module ClassMethods
      def listen(hash = {})
        @commands ||= CommandCollection.new
        @commands << hash
      end

      def commands; @commands; end

      # Resque entry
      def perform(*args)
        new.perform(*args)
      end
    end

  end
end