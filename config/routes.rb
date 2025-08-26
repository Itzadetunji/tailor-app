Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/request_magic_link', to: 'auth#request_magic_link'
      post 'auth/verify_code', to: 'auth#verify_code'
      get 'auth/verify', to: 'auth#verify_magic_link'
      get 'auth/profile', to: 'auth#profile'
      delete 'auth/logout', to: 'auth#logout'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
