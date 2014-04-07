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
        worker.command = worker.commands.match(command)
        arguments = worker.command.arguments
        arguments = arguments.unshift(sender, room)
        HubotGf::Config.perform.(worker, arguments)
      end
    end

    # Sidekiq entry
    def perform(*args)
      @sender, @room = args.shift, args.shift
      Rails.logger.info "HUBOTGF: Calling method #{method} with arguments #{args}"
      send self.class.command.method, *args
    end

    def reply(message)
      HubotGf::Messenger.new.pm(@sender, message)
    end

    def rebroadcast(message)
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