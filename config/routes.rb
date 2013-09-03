BenbenTaxi::Application.routes.draw do
  resources :sessions ,only: [:new, :create, :destroy]
  resources :tenants

  namespace :api ,defaults: {format: 'json'} do
    namespace :v1 do
      resources :users,only: [] do
        collection do
          post 'create_driver'
          post 'create_passenger'
          get  'nearby_driver'
        end
      end
      resources :sessions do
        collection do
          post 'driver_signin'
          post 'passenger_signin'
          post 'signout'
        end
      end
      resources :taxi_requests,shallow:true,only:[:create,:show,:index] do
        member do
          post 'response',action: :answer
          post 'cancel'
        end
        resources :comments,only:[:create,:index]
        collection do
          get 'nearby'
          get 'latest'
        end
      end
      resources :driver_track_points,only:[:create,:index]
      resources :advertisements,only:[:index]
      resources :client_exceptions,only:[:create]
      resources :register_verifications,only:[:create]
    end
  end

  root :to => 'main#overview'
  resources :users
  resources :client_exceptions,only:[:index,:show,:update,:edit,:destroy]
  namespace :zone_admin do
    resources :users
    resources :taxi_companies
    resources :taxi_requests
    resources :advertisements
  end

  get '/signin',  to: 'sessions#new'
  delete '/signout', to: 'sessions#destroy'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
