module HubotGf
  class Command

    attr_accessor :regex, :_method, :text

    def initialize(hash)
      @regex   = hash.keys.first
      @_method = hash.values.first
    end

    def arguments
      regex.match(text).captures
    end

    def to_s
      regex.inspect
    end

  end
end