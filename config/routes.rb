RadioCitySyp::Application.routes.draw do

  root :to => "home#index"

  match "/callback(/:provider)" => "home#callback", :as => :callback

  match "/biz" => "users#biz", :as => :biz
  match "/forgot" => "users#forgot", :as => :forgot
  match "/logout" => "users#destroy", :as => :logout

  match "/profile" => "users#profile", :as => :profile

  match '/analytics' => 'home#analytics', :as => :analytics
  match '/notifications' => 'home#notifications', :as => :notifications
  match '/sayprice(/:type)' => 'home#say_your_price', :as => :say_your_price
  match '/winners' => 'home#winners', :as => :winners
  match '/ticket_book' => 'home#ticket_book', :as => :ticket_book

  resources :products

  match '/payment/:id' => 'products#payments', :as => :payments
  
  match '/payments/:id/notify' => "products#payment_notify", :as => :payment_notify
  match '/payments/:id/cancel' => "products#payment_cancel", :as => :payment_cancel
  match '/payments/:id/return' => "products#payment_return", :as => :payment_return

  match '/download_pdf/:id' => 'products#download_pdf', :as => :download_pdf
  match "/:id" => "products#show", :as => :capsule
  


  resources :products
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
