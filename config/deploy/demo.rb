# Production
set :hostname, 'teleweave.com'
set :deploy_to, "/home/sites/#{hostname}"

# Roles
role :app, 'dude.gomoshi.com'
role :web, 'dude.gomoshi.com'
role :db,  'dude.gomoshi.com', :primary => true

# Rails environment for migrations
set :rails_env, 'demo'
