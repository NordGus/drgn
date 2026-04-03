Rails.application.routes.draw do
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, only: [ :new, :create, :edit, :update ], param: :token
  resources :invitations, only: [:show], param: :key do
    member do
      post :claim
    end
  end

  namespace :settings do
    resource :character, only: [ :show, :update, :destroy ] do
      member do
        patch :replace_password
        put :replace_password
      end
    end

    resources :invitations, only: [ :index, :create, :destroy ] do
      member do
        delete :revoke
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "application#welcome"
end
