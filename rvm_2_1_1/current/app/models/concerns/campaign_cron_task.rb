module CampaignCronTask
  extend ActiveSupport::Concern
  included do

    def self.send_scheduled_events(time_key)
        start_time,end_time = find_start_end_time(time_key)
        active_users = User.where(is_active: true)
        active_users.each do |user|
          if user.campaigns && (user.campaigns.where(is_power_share: true).count > 0 || user.campaigns.where(is_power_share: false).count > 0)
            queued_list = Delayed::Job.where(user_id: user.id, failed_at: nil, share_now: false).map(&:campaign_id).uniq
              unless queued_list.blank?
                user.campaigns.where(id: queued_list).where("to_char(schedule_on,'YYYY-MM-DD HH24:MI') >= ? AND to_char(schedule_on,'YYYY-MM-DD HH24:MI') <= ?",start_time.strftime("%Y-%m-%d %H:%M"),end_time.strftime("%Y-%m-%d %H:%M")).each do |campaign|
                  AlertLog.send_event(event_post_params('SCHEDULED_CAMPAIGN',campaign,'CAMPAIGNS',"#{ENV['CUSTOM_URL']}/#/campaigns/index?src=campaign&cid=#{campaign.campaign_uuid}",campaign.user_id,time_key)) unless campaign.is_power_share
                end
              end
          end
        end
    end

    def self.linkedin_expiry_accounts
      active_users = User.where(is_active: true)
      active_users.each do |user|
        linkedin_channels = user.user_social_channels.where(channel: "linkedin")
        unless linkedin_channels.blank?
          linkedin_channels.each do |account|
            day = (Date.parse("#{account.updated_at}") + 60.days ).mjd - Date.today.mjd
            if day < 0
              account.update_attributes(active: false)
            elsif day == 0
              AlertLog.send_event(alert_post_params(account,day))
            elsif day == 7
              AlertLog.send_event(alert_post_params(account,day))
            end
          end
        end
      end
    end

    def self.find_start_end_time(time_key)
      time = Time.now
      if time_key == '2_hours'
        start_time = time + 2.hours
        end_time = time + (2.hours + 3.minutes)
      else
        start_time = time + 1.day
        end_time = time + (1.day + 1.hour)
      end
      [start_time,end_time]
    end

    def self.alert_post_params(account,days)
      {
          :event_name => "LINKEDIN_ACCOUNT_EXPIRY",
          :user_id => account.user_id,
          :event_params => {
              :campaign_id => nil,
              :callback_url => "#{ENV['CUSTOM_URL']}/#/configure/social",
              :place_holders => {
                  "{account_name}" => account.name,
                  "{days}" => days == 7 ? "in 7 days" : "today"
              },
              :callback_app => {
                  :response_id => 0,
                  :module => 'CAMPAIGNS'
              },
              :post_state => 'QUEUED'
          }
      }
    end

    def self.event_post_params(event_name,campaign,module_name,callback_url,user_id,alert_time)
      {
          :event_name => event_name,
          :user_id => user_id,
          :event_params => {
              :campaign_id => campaign.id,
              :callback_url => callback_url,
              :place_holders => {
                  "{campaign_name}" => campaign.label,
                  "{scheduled_date}" => campaign.schedule_on.strftime('%B %d %Y'),
                  "{alert_time}" => alert_time.gsub("_"," ")
              },
              :callback_app => {
                  :response_id => campaign.id,
                  :module => module_name
              },
              :post_state => 'QUEUED'
          }
      }
    end
  end
end