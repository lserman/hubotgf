module HubotGF
  module Worker

    def self.included(base)
      @workers ||= []
      @workers << base
      base.extend ClassMethods
    end

    def self.start(command)
      worker = @workers.find { |w| w.command =~ command }
      HubotGF::Config.perform.call(worker, worker.command.match(command).captures) if worker
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