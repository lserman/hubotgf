module HubotGf
  class CommandCollection

    attr_accessor :regex, :method

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
      command = @commands.find { |cmd| cmd.regex =~ text }
      if command
        command.text = text
        command
      end
    end

  end
end