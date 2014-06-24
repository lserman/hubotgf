module HubotGf
  class CommandCollection

    attr_accessor :commands, :worker

    def initialize(worker)
      @commands = []
      @worker   = worker
    end

    def <<(hash)
      @commands << Command.new(hash)
    end

    def include?(text)
      !!match(text)
    end

    def match(text)
      if command = @commands.find { |cmd| cmd.regex =~ text }
        command.text = text
        command
      end
    end

  end
end