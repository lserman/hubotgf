module HubotGF
  class CommandsController < ActionController::Base

    def create
      result = HubotGF::Worker.start params[:command]
      head (result ? :ok : :not_found)
    end

  end
end