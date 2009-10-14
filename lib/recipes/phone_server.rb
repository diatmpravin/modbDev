namespace :phone_server do
  desc 'Start the phone server'
  task :start do
    sudo "ruby #{current_path}/script/phone_server start #{stage}"
  end

  desc 'Stop the phone server'
  task :stop do
    sudo "ruby #{current_path}/script/phone_server stop #{stage}"
  end

  desc 'Restart the phone server'
  task :restart do
    stop
    start
  end
end

after 'deploy:stop', 'phone_server:stop'
after 'deploy:start', 'phone_server:start'
after 'deploy:restart', 'phone_server:restart'
