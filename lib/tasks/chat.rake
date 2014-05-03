namespace :chat do
  desc 'Reset users online status to false'
  task :reset_users => :environment do
    User.update_all(is_online: false)
  end
end