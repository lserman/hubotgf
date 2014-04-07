require "hubotgf/engine"
require "hubotgf/config"
require "hubotgf/command_collection"
require "hubotgf/worker"
require "hubotgf/gf"

require_relative "../app/controllers/hubotgf/commands_controller"

module HubotGf

  def self.configure(&block)
    HubotGf::Config.configure(&block)
  end

end
