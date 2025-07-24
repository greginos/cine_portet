Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "home#index"

  resources :programmations, only: [ :index, :show ] do
    resources :tickets, only: [ :new, :create, :show ] do
      member do
        get :success
        get :cancel
      end
    end
  end

  namespace :staff do
    resources :programmations do
      collection do
        get "search_movies"
      end
    end
  end

  resources :memberships, only: [ :new, :create ]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
