class SocialShareJob < Struct.new(:campaign,:user_id)
	def perform
    Campaign.share_social_content(campaign,user_id)
  end

  def success(job)
    campaign = Campaign.where(id: job.campaign_id).first
    post_url = "#{ENV['CUSTOM_URL']}/#/campaigns/index?src=campaign&cid=#{campaign.campaign_uuid}"
    AlertLog.send_event(event_params('SCHEDULED_CAMPAIGN_SHARED',post_url,"CAMPAIGNS",campaign,job.user_id)) unless campaign.is_power_share && job.share_now
  end

  private

  def event_params(event_name,callback_url,module_name,campaign,user_id)
    {
        :event_name => event_name,
        :user_id => user_id,
        :event_params => {
            :campaign_id => campaign.id,
            :callback_url => callback_url,
            :place_holders => {
                "{campaign_name}" => campaign.label,
                "{scheduled_date}" => campaign.schedule_on.strftime('%B %d %Y')
            },
            :callback_app => {
                :response_id => campaign.id,
                :module => module_name
            },
            :post_state => 'HISTORY'
        }
    }
  end
end