# Stages
set :stages, %w(staging production)
set :default_stage, :staging
require 'capistrano/ext/multistage'

# Application data
set :application, 'Fleet'
set :webuser, 'www-data'
set :webgrp, 'www-data'
set :runner, 'root'

# Repository
set :scm, :git
set :repository, 'git@git.gomoshi.com:fleet.git'
set :git_shallow_clone, 1

# Copy deploy strategy
set :deploy_via, :copy
set :copy_strategy, :export
set :copy_compression, :bzip2

# Determine what branch. Order: tag => branch => master
set :branch, ENV['TAG'] || ENV['BRANCH'] || 'master'

# Dependencies

# Fix for sudo to properly use the shell
default_run_options[:pty] = true

# Set ownership after a deploy:setup
after 'deploy:setup', :roles => :app do
  sudo "chown -R #{webuser}:#{webgrp} #{deploy_to}"
end

# Update ownership after link
# Set of ownership to www-data after initial setup
after 'deploy:symlink', :set_ownership
after 'deploy:update_code', :set_ownership

task :set_ownership, :roles => :app do
  sudo "chown -R #{webuser}:#{webgrp} #{current_release}"
end

# Pull the configs in for the current stage
after 'deploy:update_code', :roles => :app do
  sudo "cp #{release_path}/config/deploy/#{stage}/*.yml #{release_path}/config/"
end

namespace :deploy do
  desc 'Start the web server'
  task :start, :roles => :app do
    sudo "ruby #{current_path}/script/device_server start #{stage}"
    sudo "ruby #{current_path}/script/phone_server start #{stage}"
  end

  desc 'Stop the web server'
  task :stop, :roles => :app do
    sudo "ruby #{current_path}/script/device_server stop #{stage}"
    sudo "ruby #{current_path}/script/phone_server stop #{stage}"
  end

  desc 'Restart the web server'
  task :restart, :roles => :app do
    sudo "ruby #{current_path}/script/device_server stop #{stage}"
    sudo "ruby #{current_path}/script/phone_server stop #{stage}"
    sudo "ruby #{current_path}/script/device_server start #{stage}"
    sudo "ruby #{current_path}/script/phone_server start #{stage}"
    sudo "touch #{current_path}/tmp/restart.txt"
  end
end
