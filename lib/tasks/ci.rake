namespace :ci do
  desc "Setup the clone for our CI server" 
  task :prepare => [:copy_config, "db:migrate"] 

  task :copy_config do
    cp "config/database.yml.test", "config/database.yml"
  end
end
