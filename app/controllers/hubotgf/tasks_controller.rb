module HubotGF
  class TasksController < ActionController::Base

    def create
      result = HubotGF::Worker.start params[:command], params[:_sender]
      head (result ? :ok : :not_found)
    end

  end
end