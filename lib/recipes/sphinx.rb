require 'thinking_sphinx/deploy/capistrano'

after 'deploy:setup', 'thinking_sphinx:shared_sphinx_folder'
after 'deploy:update_code', 'thinking_sphinx:configure'
