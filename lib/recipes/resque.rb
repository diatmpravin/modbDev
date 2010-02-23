namespace :resque do
  desc "Stop the running workers"
  task :stop, :roles => :app do
    sudo "/usr/bin/env god stop fleet-workers"
  end

  desc "Start the running workers"
  task :start, :roles => :app do
    sudo "/usr/bin/env god start fleet-workers"
  end

  desc "Restart the running workers"
  task :restart, :roles => :app do
    sudo "/usr/bin/env god restart fleet-workers"
  end
end

before 'deploy:stop',    'resque:stop'
before 'deploy:start',   'resque:start'
after  'deploy:restart', 'resque:restart'
