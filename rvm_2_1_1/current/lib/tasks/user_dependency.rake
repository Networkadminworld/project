namespace :user do

  task :remove_all_dependency_from_db, [:user_email] => :environment  do |t, args|
    user = User.where(email: args[:user_email]).first
    if user
    puts "Checking tenant information...."
    tenants = Tenant.where(client_id: user.id)
    if tenants.count > 0
      puts "#{tenants.count} tenants found. Preparing for removing tenants..."
      tenants.destroy_all
      puts "*****All tenants and dependencies removed.*****"
    else
      puts "No tenants found."
    end
    puts "Checking users information...."
    users = User.where(parent_id: user.id)
    if users.count > 0
      puts "#{users.count} users found. Preparing for removing users..."
      users.delete_all
      puts "*****All users and dependencies removed.*****"
    else
      puts "No users found."
    end
    puts "Checking for Business Customer Information"
    biz_customers = BusinessCustomerInfo.where(user_id: user.id)
    if biz_customers.count > 0
      puts "#{biz_customers.count} business customers found. Preparing for removing customers..."
      biz_customers.delete_all
      puts "*****All business customers and dependencies removed.*****"
    else
      puts "No business customers found."
    end

    puts "Checking for Campaigns Information"
    campaigns = Campaign.where(user_id: user.id)
    if campaigns.count > 0
      puts "#{campaigns.count} campaigns found. Preparing for removing customers..."
      campaigns.delete_all
      puts "*****All campaigns and dependencies removed.*****"
    else
      puts "No campaigns found."
    end

    puts "Removing given user dependencies"
    user_social_channels = UserSocialChannel.where(user_id: user.id)
    if user_social_channels.count > 0
      puts "#{user_social_channels.count} social channels found. Preparing for removing social channels..."
      user_social_channels.delete_all
    else
      puts "No social channels found."
    end
    user_mobile_channels = UserMobileChannel.where(user_id: user.id)
    if user_mobile_channels.count > 0
      puts "#{user_mobile_channels.count} mobile channels found. Preparing for removing mobile channels..."
      user_mobile_channels.delete_all
    else
      puts "No mobile channels found."
    end
    user_location_channels = UserLocationChannel.where(user_id: user.id)
    if user_location_channels.count > 0
      puts "#{user_location_channels.count} location channels found. Preparing for removing location channels..."
      user_location_channels.delete_all
    else
      puts "No location channels found."
    end
    company = Company.where(user_id: user.id).first
    company.delete if company
    puts "Removed company information"
    user.delete
    puts "All set. Done"
    else
    puts "No user found."
    end
  end

end