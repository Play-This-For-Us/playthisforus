Rails.application.routes.draw do
  resources :events, except: [:index]
  devise_for :users
  resources :users, only: [:show]
  root "home#index"
  get '/playlists/:id', to: 'playlist#show'
end
