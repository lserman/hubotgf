HubotGf::Engine.routes.draw do
  resources :commands, only: :create
end
