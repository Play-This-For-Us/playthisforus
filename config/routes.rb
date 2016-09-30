Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show]
  root "home#index"
end
