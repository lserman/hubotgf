class CommandCollection

  attr_accessor :regex, :method

  delegate :=~, :match, to: :regex

  def initialize
    @commands = []
  end

  def <<(hash)
    @commands << hash
  end

  def include?(string)
    @commands.any? { |cmd| cmd.keys[0] =~ string }
  end

  def match(string)
    @commands.each do |cmd|
      match = cmd.keys[0].match(string)
      return match if match
    end
  end

end