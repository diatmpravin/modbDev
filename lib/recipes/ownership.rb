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
