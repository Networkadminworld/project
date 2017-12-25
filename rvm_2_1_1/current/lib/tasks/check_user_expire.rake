namespace :user do
  task :check_user_expiry => :environment  do |t, args|
    users = User.all
    users.each do |user|
      if user.exp_date == ActiveSupport::TimeZone["GMT"].parse(Time.now.strftime("%Y-%m-%d 12am"))
        user.is_active = false
        user.save(validate:false)
      end  
    end  
  end
end