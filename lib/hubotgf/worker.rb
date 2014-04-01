module HubotGf
  module Worker

    def self.included(base)
      @workers ||= []
      @workers << base
      base.extend ClassMethods
    end

    def self.start(command, metadata = {})
      worker = @workers.find { |w| w.command =~ command }
      if worker
        arguments = worker.command.match(command).captures
        HubotGf::Config.perform.call(worker, arguments, metadata)
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