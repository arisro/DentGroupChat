set :stage, :staging
set :branch, "master"
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

server 'staging.chat.dentgroup.eu', user: 'aris', roles: %w{web app db}, primary: true

set :rails_env, :staging
set :enable_ssl, false

set :deploy_to, '/var/www/eu.dentgroup.chat.staging'