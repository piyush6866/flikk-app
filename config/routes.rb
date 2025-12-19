Rails.application.routes.draw do
  # Devise routes with custom controllers
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # Root path
  root "pages#home"

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
