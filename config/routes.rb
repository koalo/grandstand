Rails::Application.routes.draw do |map|
  namespace :admin, :path => Grandstand.admin[:domain] ? '' : 'admin', :constraints => {:domain => Grandstand.admin[:domain]} do
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

      resources :images, :except => [:show] do
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
end
