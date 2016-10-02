Rails.application.routes.draw do
  resources :events
  devise_for :users
  resources :users, only: [:show]
  root "home#index"
end
