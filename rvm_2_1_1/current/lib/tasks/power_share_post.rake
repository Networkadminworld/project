namespace :power_share do
	
  task :scheduled_post, [:frequent] => :environment  do |t, args|
    Campaign.send_scheduled_events(args[:frequent])
  end

  task :check_linkedin_expiry => :environment  do |t, args|
    Campaign.linkedin_expiry_accounts
  end

end