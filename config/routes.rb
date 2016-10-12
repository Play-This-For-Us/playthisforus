Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  resources :events, except: [:index] do
    get 'join', on: :collection
    post 'create_join', on: :collection
  end
  devise_for :users
  resources :users, only: [:show]
  root "home#index"
  get '/join/:join_code', to: 'events#create_join'
end
