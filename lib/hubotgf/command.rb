module HubotGf
  class Command

    attr_accessor :regex, :method, :text

    def initialize(hash)
      @regex  = hash.keys.first
      @method = hash.values.first
    end

    def arguments
      regex.match(text).captures
    end

  end
end