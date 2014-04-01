require "hubotgf/engine"
require "hubotgf/config"
require "hubotgf/worker"
require "hubotgf/gf"

require_relative "../app/controllers/hubotgf/tasks_controller"

module HubotGF

  def self.configure(&block)
    HubotGF::Config.configure(&block)
  end

end
