Rails.application.routes.draw do
  get 'users/new'
  root "static_pages#home"
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get "/news", to: "static_pages#news"
  get "/signup", to: "users#new"
  get    "/login",   to: "sessions#new"
  post   "/login",   to: "sessions#create"
  delete "/logout",  to: "sessions#destroy"
  get "/user_not_found", to: "users#user_not_found"
  resources :users
  resources :account_activations, only: [:edit]
end
