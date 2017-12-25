namespace :campaigns do

  task :remove_shared_csv_files => :environment  do |t, args|
    start_time = Time.now - 7.days
    active_users = User.where(is_active: true)
    active_users.each do |user|
      if user.campaigns && (user.campaigns.where(is_power_share: true).count > 0 || user.campaigns.where(is_power_share: false).count > 0)
        queued_list = Delayed::Job.where(user_id: user.id, failed_at: nil, share_now: false).map(&:campaign_id).uniq
        user.campaigns.where.not(id: queued_list).where("to_char(schedule_on,'YYYY-MM-DD') <= ?",start_time.strftime("%Y-%m-%d")).each do |campaign|
          dir = "#{Rails.root}/public/campaign_share_files/#{user.id}/"
          if File.directory?(dir)
            Dir.foreach(dir) do |fname|
              if [".csv"].include? File.extname(fname)
                if fname.split("_")[4].to_i == campaign.id
                  name = "#{dir}#{fname}"
                  File.delete(name)
                  puts "Removed file: #{fname}"
                end
              end
            end
          end
        end
      end
    end
  end
end