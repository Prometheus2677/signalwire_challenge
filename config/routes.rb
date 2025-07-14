Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :tickets, only: [:create]
    end
  end

  # Root route - Simple UI for testing
  root "home#index"

  # Debug routes for viewing data
  get "debug/tickets" => "debug#tickets"
  get "debug/tags" => "debug#tags"
end
