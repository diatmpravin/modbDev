namespace :device_server do
  desc 'Start the device server'
  task :start do
    sudo "ruby #{current_path}/script/device_server start #{stage}"
  end

  desc 'Stop the device server'
  task :stop do
    sudo "ruby #{current_path}/script/device_server stop #{stage}"
  end

  desc 'Restart the device server'
  task :restart do
    stop
    start
  end
end

after 'deploy:stop', 'device_server:stop'
after 'deploy:start', 'device_server:start'
after 'deploy:restart', 'device_server:restart'
