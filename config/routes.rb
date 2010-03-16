ActionController::Routing::Routes.draw do |map|
  # Root
  map.root :controller => 'devices'
  
  # Accounts
  map.resources :accounts
  
  # Sessions
  map.resources :sessions
  map.login '/login', :controller => 'sessions', :action => 'new', :conditions => {:method => :get}
  map.connect '/login', :controller => 'sessions', :action => 'create', :conditions => {:method => :post}
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  # Maps
  map.resources :maps, :collection => {:status => :get}, :member => {:status => :get}
  
  # Users
  map.resources :users, :collection => {
    :resend_activation => :get,
    :forgot_password => :get,
    :reset_password => :get,
    :set_password => :get
  }, :member => {
    :activate => :get
  }

  map.forgot_password '/users/forgot_password', :controller => 'users', :action => 'forgot_password', :conditions => {:method => :post}
  map.reset_password '/users/reset_password/:id', :controller => 'users', :action => 'reset_password'
  map.set_password '/users/set_password/:id', :controller => 'users', :action => 'set_password'

  map.resource :profile, :controller => 'profile'
  
  # Devices
  map.resources :devices, :member => {:position => :get}, :collection => {
    :apply_profile => :post,
    :apply_group => :post,
    :remove_group => :post,
    :live_look => :get
  } do |devices|
    devices.resources :trips
    devices.resources :geofences
  end
  
  map.resources :device_profiles
  
  # Trips
  map.resources :trips, :member => {:collapse => :put, :expand => :put}, :collection => {:summary => :get}
  
  # Geofences
  map.resources :geofences
  
  # Landmarks
  map.resources :landmarks
  
  # Alert Recipients
  map.resources :alert_recipients
  
  # Tags
  map.resources :tags
  
  # Trackers (Administration)
  map.resources :trackers, :member => {
    :configure => :post,
    :get_info => :post
  }
  
  # Reports
  map.resources :reports

  # Filter
  map.resource :filter

  # Groups
  map.resources :groups, :member => {
      :live_look => :get
  } do |group|
    group.resources :geofences, :controller => 'geofences'
  end
  
  # Subscriptions
  map.resource :subscription, :controller => 'subscription',
    :member => {
      :edit_plan => :get
    }
  
  # Payments
  map.resources :payments

  # Imports
  map.namespace :import do |import|
    import.resources :vehicles
  end

  # Report Card
  map.resource :report_card, :controller => "report_card"

  # Billing Tester
  map.billing_tester '/billing_tester/:action', :controller => 'billing_tester'

  # Static Pages
  map.resource :contact
  
end
