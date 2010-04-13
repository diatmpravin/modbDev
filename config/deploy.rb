# Stages
set :stages, %w(staging demo production)
set :default_stage, :staging
require 'capistrano/ext/multistage'

# Application data
set :application, 'Fleet'
set :webuser, 'www-data'
set :webgrp, 'www-data'
set :runner, 'root'

# Repository
set :scm, :git
set :repository, 'git@git.gomoshi.com:mobd/fleet.git'
set :git_shallow_clone, 1

# Copy deploy strategy
set :deploy_via, :copy
set :copy_strategy, :export
set :copy_compression, :bzip2
set :copy_exclude, 'doc/resources'

# Determine what branch. Order: tag => branch => master
set :branch, ENV['TAG'] || ENV['BRANCH'] || 'master'

# Dependencies
depend(:remote, :gem, 'newrelic_rpm', '>= 2.9.5')
depend(:remote, :gem, 'ruport', '>= 1.6.1')

# Fix for sudo to properly use the shell
default_run_options[:pty] = true

def rake(*tasks)
  rails_env = fetch(:rails_env, "production")
  rake = fetch(:rake, "rake")
  tasks.each do |t|
    sudo "echo ''"
    run "if [ -d #{release_path} ]; then cd #{release_path}; else cd #{current_path}; fi; sudo -u www-data #{rake} RAILS_ENV=#{rails_env} #{t}"
  end
end

# Set ownership after a deploy:setup
after 'deploy:setup', :roles => :app do
  sudo "chown -R #{webuser}:#{webgrp} #{deploy_to}"
end

# Pull the configs in for the current stage
after 'deploy:update_code', :roles => :app do
  sudo "cp #{release_path}/config/deploy/#{stage}/*.yml #{release_path}/config/"

  sudo "chown -R #{webuser}:#{webgrp} #{release_path}"
  sudo "chmod -R g+w #{release_path}"

  # Force parse the CSS on deploy
  rake "more:parse"
end

namespace :deploy do
  desc 'Start the web server'
  task :start, :roles => :app do
    # NOOP
  end

  desc 'Stop the web server'
  task :stop, :roles => :app do
    # NOOP
  end

  desc 'Restart the web server'
  task :restart, :roles => :app do
    sudo "touch #{current_path}/tmp/restart.txt"
  end
end
