require "bundler/capistrano" 
require "capistrano-unicorn"
require "rvm/capistrano"

set :application, "DRS Chat"
set :repository,  "git@github.com:arisro/DentGroupChat.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true, :port => 443 }
set :keep_releases, 5

before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'
set :rvm_ruby_string, '2.0.0-p353'

set :deploy_to, "/var/www/com.buzachis-aris.chat"
set :rails_env, "development"
set :user, 'aris'

task :production do
  server "chat.dent-group.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/com.dent-group.chat"
  set :rails_env, "production"
end

task :staging do
  server "chat.buzachis-aris.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/com.buzachis-aris.chat"
  set :rails_env, "development"
end

namespace :deploy do
  task :copy_config_files do
    put File.read("config/initializers/secret_token.rb.dist"), "#{shared_path}/config/secret_token.rb"
  end
  after "deploy:setup", "deploy:copy_config_files"
  
  desc "Symlink shared config files"
  task :symlink_config_files do
      run "#{try_sudo} ln -nfs #{deploy_to}/shared/config/database.yml #{deploy_to}/releases/#{release_name}/config/database.yml"
      run "#{try_sudo} ln -nfs #{deploy_to}/shared/config/secret_token.rb #{deploy_to}/releases/#{release_name}/config/initializers/secret_token.rb"
  end
  after "deploy:finalize_update", "deploy:symlink_config_files"
  
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "#{try_sudo} /etc/init.d/unicorn_#{application}_#{rails_env} #{command}"
    end
  end

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do 
      run_locally("rm -rf public/assets/*") 
      run_locally("RAILS_ENV=#{rails_env} bundle exec rake assets:precompile --trace") 
      servers = find_servers_for_task(current_task) 
      port = 443
      port_option = port ? " -e 'ssh -p #{port}' " : '' 
      servers.each do |server| 
        run_locally("rsync --recursive --times --rsh=ssh --compress #{port_option} --progress public/assets #{user}@#{server}:#{shared_path}") 
      end 
    end
  end
end

after 'deploy:finalize_update', 'deploy:migrate'