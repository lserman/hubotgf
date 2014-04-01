HubotGf::Engine.routes.draw do
  resources :tasks, only: :create
  # post '/hubotgf/tasks', controller: 'hubot_gf/tasks', action: 'create'
end
