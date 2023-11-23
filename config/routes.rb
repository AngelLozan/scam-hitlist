# frozen_string_literal: true

Rails.application.routes.draw do
  
  get 'health/ready', to: 'health#readiness'
  get 'health/live', to: 'health#liveness'

  resources :hosts
  resources :forms
  resources :iocs do
    collection do
      post :simple_create
    end
  end
  # Route for reported only. Sort by follow up date there.
  get '/reported', to: 'iocs#reported', as: 'reported'
  get '/follow_up', to: 'iocs#follow_up', as: 'follow_up'

  # devise_for :users, controllers: {
  #   omniauth_callbacks: 'users/omniauth_callbacks'
  # }

  devise_for :users, controllers: {
    registrations: 'custom_devise/registrations'
  }

  get '/users/new', to: 'users#new', as: 'new_user'
  delete "users/:id", to: "users#destroy"
  devise_scope :users do
    post '/users', to: 'custom_devise/registrations#create', as: 'create_user'
  end
  get '/users', to: 'users#index', as: 'users'
  get '/users/:id/', to: 'users#show', as: 'user'
  
  
  get '/2b_reported', to: 'iocs#tb_reported', as: 'tb_reported'
  get '/watchlist', to: 'iocs#watchlist', as: 'watchlist'

  get '/settings', to: 'pages#settings', as: 'settings'

  get '/ca/:id/', to: 'iocs#ca', as: 'chain_abuse'
  # get '/mini_bb', to: 'pages#rubric', as: 'bug_bounty'

  get '/presigned', to: 'iocs#presigned', as: 'presigned'
  get '/download_presigned', to: 'iocs#download_presigned', as: 'download_presigned'

  root to: 'pages#home'

  authenticate :user, ->(user) { user.admin == true } do
    mount Blazer::Engine, at: "data", as: "data"
  end
end
