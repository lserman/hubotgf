HubotGf::Engine.routes.draw do
  resources :tasks, only: :create
end
