ActionController::Routing::Routes.draw do |map|
  # Root
  map.root :controller => 'maps'
  
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
    :reset_password => :get
  }, :member => {
    :activate => :get
  }

  map.forgot_password '/users/forgot_password', :controller => 'users', :action => 'forgot_password', :conditions => {:method => :post}
  map.reset_password '/users/reset_password/:id', :controller => 'users', :action => 'reset_password'

  map.resource :profile, :controller => 'profile'
  
  # Devices
  map.resources :devices, :member => {:position => :get} do |devices|
    devices.resources :trips
    devices.resources :geofences
  end
  
  # Trips
  map.resources :trips, :member => {:collapse => :put, :expand => :put}, :collection => {:summary => :get}
  
  # Geofences
  map.resources :geofences
  
  # Landmarks
  map.resources :landmarks
  
  # Phones
  map.resources :phones, :collection => {
    :activate => [:post],
    :download => [:put]
  }
  
  # Phone communication & control
  map.dispatch '/dispatch', :controller => 'dispatch', :action => 'index'
  
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
  
  # Subscriptions
  map.resource :subscription, :controller => 'subscription',
    :member => {
      :edit_plan => :get
    }
  
  # Payments
  map.resources :payments

  # Billing Tester
  map.billing_tester '/billing_tester/:action', :controller => 'billing_tester'
  
  # Phone Finder
  map.resource :phone_finder, :controller => 'phone_finder', :collection => {
    :popup => :get,
    :carrier => :get,
  } do |phone_finder|
    
    # /phone_finder/carriers
    phone_finder.resources :carriers, :controller => 'phone_finder/carriers' do |carriers|
      
      # /phone_finder/carriers/:id/phones
      carriers.resources :phones, :controller => 'phone_finder/carriers/phones'
    end
  end
  
  # Admin Site
  map.admin '/admin', :controller => 'admin/menu', :action => 'show'
  map.namespace(:admin) do |admin|
    # Sessions
    admin.resources :sessions
      map.admin_login '/admin/login', :controller => 'admin/sessions', :action => 'new',
      :conditions => { :method => :get }
    map.connect '/admin/login', :controller => 'admin/sessions', :action => 'create',
      :conditions => { :method => :post }
    map.admin_logout '/admin/logout', :controller => 'admin/sessions', :action => 'destroy'
    
    # Menu
    admin.resource :menu, :controller => 'menu'
  end
end
