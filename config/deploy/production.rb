set :stage, :production
set :branch, "master"
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

server 'chat.dent-group.com', user: 'aris', roles: %w{web app db}, primary: true

set :rails_env, :production
set :enable_ssl, false