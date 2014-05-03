set :stage, :production
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

server 'chat.dentgroup.eu', user: 'aris', roles: %w{web app db}, primary: true

set :rails_env, :production
set :enable_ssl, false