Conbase::Application.routes.draw do

  match '/programs/public/:time/:sort(/:group)', :to => 'programs#public'

  resources :events

  resources :people do
    get 'duplicategrouplist', :on => :collection
    get 'duplicates', :on => :collection
    get 'search', :on => :collection
    get 'rmgroup', :on => :collection
  end

  resources :persongroups

  resources :purchases do
    get 'lipputilaus', :on => :collection
  end

  resources :product_types

  resources :products

  resources :attributes

  resources :locations

  resources :programitems

  resources :exhibitors do
    get 'rmproduct', :on => :collection
    get 'newen'
    get "createen"
  end

  resources :programgroups

  match '/:controller(/:action(/:id))'
  root :to => 'login#login'
end
