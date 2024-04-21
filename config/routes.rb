# frozen_string_literal: true

require_relative '../lib/admin_scope_constraint'
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth/callbacks' }

  scope :admin, as: :admin do
    constraints AdminScopeConstraint.new do
      # Setting up sidekiq web: https://github.com/sidekiq/sidekiq/wiki/Monitoring#web-ui
      mount Sidekiq::Web => '/sidekiq'
      mount Flipper::Api.app(Flipper) => '/flipper/api'
      mount Flipper::UI.app(Flipper) => '/flipper'
    end
  end

  resources :services, except: %i[destroy]
  resources :products, except: %i[destroy]
  resources :accounts, except: %i[destroy]
  get 'businesses', to: 'accounts#index', as: :businesses
  get 'businesses/new', to: 'accounts#new', as: :new_business
  get 'businesses/:id', to: 'accounts#show', as: :business
  get 'businesses/:id/edit', to: 'accounts#edit', as: :edit_business
  post 'businesses', to: 'accounts#create'
  match 'businesses/:id', to: 'accounts#update', via: %i[patch put]

  get 'pages/home'
  get 'pages/dashboard'

  match 'app/*path', to: 'pages#home', via: :get

  root to: 'pages#home'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  match '*unmatched', to: 'errors#emit_routing_exception', via: :all
end
