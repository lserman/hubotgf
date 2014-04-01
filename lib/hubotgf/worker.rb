module HubotGf
  module Worker

    def self.included(base)
      @workers ||= []
      @workers << base
      base.extend ClassMethods
    end

    def self.start(command, sender = nil)
      worker = @workers.find { |w| w.command =~ command }
      if worker
        arguments = worker.command.match(command).captures << sender
        HubotGf::Config.perform.call(worker, arguments)
      end
    end

    def gf
      HubotGf::Messenger.new
    end

    module ClassMethods
      def command=(command)
        @command = command
      end

      def command
        @command || ''
      end
    end

  end
end