# frozen_string_literal: true

require_relative '../lib/admin_scope_constraint'
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  resources :invoices
  get 'healthz', to: 'healthz#show'

  devise_for :users,
             controllers: {
               sessions: 'users/passwordless',
               passwords: 'users/passwords',
               registrations: 'users/registrations',
               confirmations: 'users/confirmations',
               unlocks: 'users/unlocks',
               omniauth_callbacks: 'users/omniauth/callbacks'
             }

  devise_scope :user do
    get 'users/fallback/sign_in', as: :new_user_fallback_session, to: 'users/sessions#new'
    post 'users/fallback/sign_in', as: :user_fallback_session, to: 'users/sessions#create'
    delete 'users/fallback/sign_out', as: :destroy_user_fallback_session, to: 'users/sessions#destroy'
  end

  scope :admin, as: :admin do
    constraints AdminScopeConstraint.new do
      # Setting up sidekiq web: https://github.com/sidekiq/sidekiq/wiki/Monitoring#web-ui
      mount Sidekiq::Web => '/sidekiq'
      mount Flipper::Api.app(Flipper) => '/flipper/api'
      mount Flipper::UI.app(Flipper) => '/flipper'
    end
  end

  resources :invoices, except: %i[destroy]
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

  root to: 'pages#home'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  match '*unmatched', to: 'errors#emit_routing_exception', via: :all
end
