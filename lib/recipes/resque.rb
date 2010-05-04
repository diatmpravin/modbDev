namespace :resque do
  desc "Stop the running workers"
  task :stop, :roles => :app do
    sudo "/usr/bin/monit -g fleet_workers stop"
  end

  desc "Start the running workers"
  task :start, :roles => :app do
    sudo "/usr/bin/monit -g fleet_workers start"
  end

  desc "Restart the running workers"
  task :restart, :roles => :app do
    sudo "/usr/bin/monit -g fleet_workers restart"
  end
end

before 'deploy:stop',    'resque:stop'
before 'deploy:start',   'resque:start'
after  'deploy:restart', 'resque:restart'
