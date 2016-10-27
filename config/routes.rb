# frozen_string_literal: true
Rails.application.routes.draw do
  # websocket
  mount ActionCable.server => '/cable'

  # landing page
  root 'home#index'

  # users and authentication
  devise_for :users
  resources :users, only: [:show]

  # spotify user oauth authentication
  get '/auth/spotify/callback', to: 'users#spotify'

  # events management and joining
  resources :events, except: [:index] do
    post 'start_playing', on: :member
    post 'stop_playing', on: :member
    post 'create_new_playlist', on: :member
  end

  get 'join(/:join_code)' => 'events#join', :as => :join_events
end
