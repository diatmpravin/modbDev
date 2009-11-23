# Capistrano tasks for Sphinx.
#
# There are capistrano tasks available as part of the library but they don't
# meet our needs for monitoring and management. Some of the tasks have been
# copied directly from the thinking sphinx gem.

# TODO: Needs to be made aware of primary search server if there are multiple running
namespace :sphinx do
  desc "Start the Sphinx daemon"
  task :start do
    configure
    sudo "monit start fleet-sphinx"
  end

  desc "Stop the Sphinx daemon"
  task :stop do
    configure
    sudo "monit stop fleet-sphinx"
  end

  desc "Stop and then start the Sphinx daemon"
  task :restart do
    configure
    sudo "monit restart fleet-sphinx"
  end

  desc "Generate the Sphinx configuration file"
  task :configure do
    rake "thinking_sphinx:configure"
  end

  desc "Index data"
  task :index do
    rake "thinking_sphinx:index"
  end

  desc "Stop, re-index and then start the Sphinx daemon"
  task :rebuild do
    stop
    index
    start
  end

  desc "Create the shared folder for the sphinx database"
  def setup
    run "mkdir -p #{shared_path}/db/sphinx/#{fetch(:rails_env, "production")}"
  end

  def rake(*tasks)
    rails_env = fetch(:rails_env, "production")
    rake = fetch(:rake, "rake")
    tasks.each do |t|
      sudo "echo ''"
      run "if [ -d #{release_path} ]; then cd #{release_path}; else cd #{current_path}; fi; sudo #{rake} RAILS_ENV=#{rails_env} #{t}"
    end
  end
end

after 'deploy:setup', 'sphinx:setup'
after 'deploy:update_code', 'sphinx:configure'

# Link over the shared search database
after 'deploy:update_code' do
  sudo "ln -s #{shared_path}/db/sphinx #{release_path}/db"
end
