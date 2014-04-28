namespace :deploy do
  desc 'Restart unicorn application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
		run <<-CMD
			cd #{release_path}/current; bundle exec thin restart
	    CMD
    end
  end
end