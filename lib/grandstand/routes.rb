Grandstand::Application.routes.draw do |map|
  resources :galleries, :only => [:index, :show]
  match ':year/:month/:id', :to => 'posts#show', :as => 'post', :constraints => {:year => /\d\d\d\d/, :month => /\d{1,2}/}

  namespace :admin do
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

  match '*url', :to => 'pages#show', :as => 'page'
end
