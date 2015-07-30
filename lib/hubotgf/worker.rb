 module HubotGf
  module Worker

    def self.included(base)
      @workers ||= []
      @workers << base
      base.send :include, HubotGf::SidekiqEntry
      base.extend(HubotGf::ResqueEntry)
      base.extend(ClassMethods)
    end

    # Grabs command from the controller and starts the worker according to HubotGf::Config.perform
    def self.start(command, sender = nil, room = nil)
      worker = @workers.find { |w| w.commands && w.commands.include?(command) }
      if worker
        command = worker.commands.match(command)
        arguments = command.arguments.unshift(command._method, sender, room)
        HubotGf::Config.perform.call worker, arguments
      elsif worker = HubotGf::Config.catchall_worker
        HubotGf::Config.perform.call worker, [:call, sender, room, command]
      end
    end

    def reply(message)
      if pm?
        pm(message)
      else
        broadcast(message)
      end
    end

    def pm(message)
      messenger.pm(@sender, message)
    end

    def broadcast(message)
      messenger.broadcast(@room, message)
    end

    def pm?
      @sender == @room
    end

    def messenger
      @_messenger = HubotGf::Messenger.new
    end

    module ClassMethods
      def self.extended(base)
        attr_reader :commands
      end

      def listen(hash = {})
        @commands ||= CommandCollection.new(self)
        @commands << hash
      end
    end

  end
end
