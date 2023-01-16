Rails.application.routes.draw do
  root to: 'dashboards#index'
  devise_for :users
  resources :payments, only: [:new, :create, :show]
  resources :uploads, only: [:new, :create, :show]

  # config/routes.rb
  get '/payments/new', to: 'payments#new', as: 'new_transaction'
  post '/payments', to: 'payments#create'
  get '/success', to: 'payments#success'
  post "/create-checkout-session", to: "payments#create"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
