Rails.application.routes.draw do
  namespace :grandstand do
    resource :session do
      member do
        get :forgot
        post :reset
      end
    end

    root :to => 'main#index'
    get 'expand', :to => 'main#expand'

    resources :galleries do
      collection do
        post :reorder
      end

      member do
        get :delete
      end

      resources :images do
        collection do
          post :reorder
          get :upload
        end

        member do
          get :delete
        end
      end
    end

    resources :pages do
      collection do
        post :reorder
      end

      member do
        get :delete
      end
    end

    resources :posts do
      member do
        get :delete
      end
    end

    resources :templates

    resources :users do
      member do
        get :delete
      end
    end
  end

  match '*url', :to => 'pages#show', :as => 'page'
  # if Rails.env.development?
  #   require 'grandstand/stylesheets_controller'
  #   namespace :grandstand do
  #     get 'stylesheets/:name.css', :to => 'stylesheets#show'
  #   end
  # end
end
