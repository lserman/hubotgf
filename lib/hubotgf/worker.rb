 module HubotGf
  module Worker

    def self.included(base)
      @workers ||= []
      @workers << base
      base.extend(ClassMethods)
    end

    def self.start(command, sender = nil, room = nil)
      worker = @workers.find { |w| w.commands.include? command }
      if worker
        command = worker.commands.match(command)
        arguments = command.arguments.unshift(command._method, sender, room)
        HubotGf::Config.perform.(worker, arguments)
      end
    end

    # Sidekiq entry
    def perform(method, sender, room, *args)
      @sender, @room = sender, room
      send method, *args
    end

    def reply(message)
      HubotGf::Messenger.new.pm(@sender, message)
    end

    def broadcast(message)
      HubotGf::Messenger.new.broadcast(@room, message)
    end

    module ClassMethods
      def self.extended(base)
        attr_accessor :command
      end

      def listen(hash = {})
        @commands ||= CommandCollection.new(self)
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