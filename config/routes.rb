Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  resources :events, except: [:index]
  devise_for :users
  resources :users, only: [:show]
  root "home#index"
  get '/playlists/:id', to: 'playlist#show'
  get '/join/', to: 'events#join'
end
