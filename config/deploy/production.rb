# Production
set :hostname, 'fleet.gomoshi.com'
set :deploy_to, "/home/sites/#{hostname}"

# Roles
role :app, 'walter.gomoshi.com'
role :web, 'walter.gomoshi.com'
role :db,  'walter.gomoshi.com', :primary => true

# Rails environment for migrations
set :rails_env, 'production'