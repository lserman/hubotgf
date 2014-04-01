class TestWorker
  include HubotGf::Worker

  command /Make (.*) a (.*)/

  def perform(who, what)
    "Made #{who} a #{what}"
  end

end