require "hubotgf/engine"
require "hubotgf/config"
require "hubotgf/worker"

require_relative "../app/controllers/hubotgf/commands_controller"

module HubotGF

  def self.configure(&block)
    HubotGF::Config.configure(&block)
  end

end
