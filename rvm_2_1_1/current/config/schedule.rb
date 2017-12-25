 # Use this file to easily define all of your cron jobs.
 #
 # It's helpful, but not entirely necessary to understand cron before proceeding.
 # http://en.wikipedia.org/wiki/Cron

 # Example:
 #
 # set :output, "/path/to/my/cron_log.log"
 #
 # every 2.hours do
 #   command "/usr/bin/some_great_command"
 #   runner "MyModel.some_method"
 #   rake "some:great:rake:task"
 # end
 #
 # every 4.days do
 #   runner "AnotherModel.prune_old_records"
 # end

 # Learn more: http://github.com/javan/whenever

 # set :output, "/home/user/Desktop/projects/inquirly/cron_log.log"
 # set :environment, 'development'
 # env :PATH, ENV['PATH']

 every 3.minutes do
      rake "power_share:scheduled_post[2_hours]"
 end

 every 1.hours do
      rake "power_share:scheduled_post[1_day]"
 end

 every :day, :at => '12:00am' do
      rake "power_share:check_linkedin_expiry"
      rake "campaigns:remove_shared_csv_files"
      rake "user:check_user_expiry"
      rake "user:pricing_plan_activate"
 end