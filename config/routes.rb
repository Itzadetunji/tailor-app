Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    # namespace :api → /api/...
    namespace :v1 do
      # namespace :v1 → /api/v1/...
      # Authentication routes
      post "auth/request_magic_link", to: "auth#request_magic_link"
      post "auth/verify_code", to: "auth#verify_code"
      get "auth/verify", to: "auth#verify_magic_link"
      get "auth/profile", to: "auth#profile"
      delete "auth/logout", to: "auth#logout"

      # Client routes
      resources :clients, except: [ :destroy ] do
        # GET /api/v1/clients → ClientsController#index
        # GET /api/v1/clients/:id → ClientsController#show
        # POST /api/v1/clients → ClientsController#create
        # PATCH /api/v1/clients/:id → ClientsController#update
        # PUT /api/v1/clients/:id → ClientsController#update
        collection do
          delete :bulk_delete # DELETE /api/v1/clients/bulk_delete → ClientsController#bulk_delete
        end
      end

      # Custom field routes
      resources :custom_fields
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
