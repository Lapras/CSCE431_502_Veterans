# frozen_string_literal: true

Rails.application.routes.draw do
  get 'recurring_excusals/index'
  get 'recurring_excusals/new'
  get 'recurring_excusals/create'
  get 'excusal_requests/new'
  get 'excusal_requests/create'
  get 'not_a_member', to: 'static_pages#not_a_member', as: :not_a_member
  post '/request_membership', to: 'membership_requests#create'

  namespace :admin do
    resources :users
    resource :dashboard, only: [:show] # Admin dashboard
    resources :membership_requests, only: [:index] do
      member do
        patch :approve
        patch :deny
      end
    end
    resources :attendance_reports, only: [:index]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :events do
    resources :attendances, only: %i[index edit update] do
      collection do
        post :check_in
        post :bulk_update
      end
    end

    member do
      get :event_confirm_delete
    end
  end

  resources :excusal_requests, only: %i[new create] do
    resources :approvals, only: [:create]
  end

  resources :approvals, only: [:index]

  resources :recurring_excusals, only: %i[index new create] do
    resources :recurring_approvals, only: [:create]
  end

  root to: 'dashboards#show'
  resource :dashboard, only: [:show] # User dashboard

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
