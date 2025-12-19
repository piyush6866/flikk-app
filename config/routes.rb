Rails.application.routes.draw do
  # Devise routes with custom controllers
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # Root path
  root "pages#home"

  # Campaigns (Marketplace for Creators, Campaign Management for Brands)
  resources :campaigns do
    # Apply to campaign (creates a submission)
    post 'apply', to: 'submissions#create', as: :apply
  end

  # Submissions (Creator workflow)
  resources :submissions, only: [:show, :edit, :update]

  # Brand dashboard
  namespace :brand do
    get 'dashboard', to: 'dashboard#show'
  end

  # Creator dashboard
  namespace :creator do
    get 'dashboard', to: 'dashboard#show'
  end

  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check
end
