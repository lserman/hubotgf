module HubotGF
  module Worker

    def self.included(base)
      @workers ||= []
      @workers << base
      base.extend(ClassMethods)
      delegate :method, :command, to: :class
    end

    def self.start(command, sender = nil, room = nil)
      return unless worker = @workers.find { |w| w.command =~ command }
      arguments = worker.command.match(command).captures
      arguments = arguments.unshift(sender, room)
      HubotGf::Config.perform.(worker, arguments)
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
      def listen(hash = nil)
        @command = hash.keys[0]
        @method  = hash.values[0]
      end

      def command; @command; end
      def method; @method; end

      # Resque entry
      def perform(*args)
        new.perform(*args)
      end

    end

  end
end