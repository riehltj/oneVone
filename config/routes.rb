Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#index"
  get "home", to: "home#index", as: :home
  get "dashboard", to: "dashboard#show", as: :dashboard
  resources :availabilities, only: %i[index new create edit update destroy]
  resources :leagues, only: %i[index show], path: "pools" do
    get "join_success", on: :member, action: :join_success, as: :join_success
    resource :league_membership, only: %i[create destroy], path: "membership", as: :membership
    resources :matches, only: %i[create], path: "challenges"
  end
  resources :matches, only: %i[update]
  post "stripe_webhook", to: "stripe_webhooks#create"
end
