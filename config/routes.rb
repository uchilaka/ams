# frozen_string_literal: true

require_relative '../lib/admin_scope_constraint'
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  resources :services, except: %i[destroy]
  resources :products, except: %i[destroy]
  resources :accounts, except: %i[destroy]
  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth/callbacks' }

  scope :admin, as: :admin do
    constraints AdminScopeConstraint.new do
      # Setting up sidekiq web: https://github.com/sidekiq/sidekiq/wiki/Monitoring#web-ui
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  get 'pages/home'
  get 'pages/dashboard'

  root to: 'pages#home'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  match '*unmatched', to: 'errors#handle_routing_exception', via: :all
end
