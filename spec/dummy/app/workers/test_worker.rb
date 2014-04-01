class TestWorker
  include HubotGF::Worker

  command /Make (.*) a (.*)/

  def perform(who, what)
    "Made #{who} a #{what}"
  end

end