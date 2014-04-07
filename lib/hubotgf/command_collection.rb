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
      @commands.any? { |cmd| cmd.regex =~ text }
    end

    def match(text)
      command = @commands.find { |cmd| cmd.regex =~ text }
      command.text = text
      command
    end

  end
end