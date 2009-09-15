# Staging
set :hostname, 'fleet.gomoshi.com'
set :deploy_to, "/home/sites/#{hostname}"

# Roles
role :app, 'bunny.gomoshi.com'
role :web, 'bunny.gomoshi.com'
role :db,  'bunny.gomoshi.com', :primary => true

# Rails environment for migrations
set :rails_env, 'staging'