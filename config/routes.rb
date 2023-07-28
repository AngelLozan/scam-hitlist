# frozen_string_literal: true

Rails.application.routes.draw do
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

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  get '/2b_reported', to: 'iocs#tb_reported', as: 'tb_reported'
  get '/watchlist', to: 'iocs#watchlist', as: 'watchlist'

  get '/settings', to: 'pages#settings', as: 'settings'

  get '/ca/:id/', to: 'iocs#ca', as: 'chain_abuse'
  # get '/mini_bb', to: 'pages#rubric', as: 'bug_bounty'

  root to: 'pages#home'
end
