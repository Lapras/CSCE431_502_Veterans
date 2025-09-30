# frozen_string_literal: true

Rails.application.routes.draw do
  get 'not_a_member', to: 'static_pages#not_a_member', as: :not_a_member

  namespace :admin do
    resources :users
    resource :dashboard, only: [:show] # Admin dashboard
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :events do
    member do
      get :event_confirm_delete
    end
  end

  root to: 'dashboards#show'
  resource :dashboard, only: [:show] # User dashboard

  resources :events do
    member do
      get :event_confirm_delete
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'users/sign_in', to: 'users/sessions#new', as: :new_user_session
    get 'users/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end
end