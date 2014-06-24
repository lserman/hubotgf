module HubotGf
  module SidekiqEntry

    def perform(method, sender, room, *args)
      @sender, @room = sender, room
      send method, *args
    end

  end
end