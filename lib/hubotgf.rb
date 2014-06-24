require "hubotgf/engine"
require "hubotgf/config"
require "hubotgf/command"
require "hubotgf/command_collection"
require "hubotgf/worker"
require "hubotgf/messenger"
require "hubotgf/sidekiq_entry"
require "hubotgf/resque_entry"

require_relative "../app/controllers/hubotgf/tasks_controller"

module HubotGf
  def self.configure(&block)
    HubotGf::Config.configure(&block)
  end
end
