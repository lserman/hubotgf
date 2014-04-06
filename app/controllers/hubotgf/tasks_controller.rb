module HubotGf
  class TasksController < ActionController::Base

    def create
      result = HubotGf::Worker.start(params[:command], params[:_sender], params[:_room])
      head (result ? :ok : :not_found)
    end

  end
end