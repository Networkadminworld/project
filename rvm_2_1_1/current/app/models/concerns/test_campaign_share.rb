module TestCampaignShare
  extend ActiveSupport::Concern
  included do

    def self.share_campaign(params)
      user = User.inq_test_user
      params.merge!(campaign_params(user))
       if params[:campaign_uuid]
        campaign = where(campaign_uuid: params[:campaign_uuid]).first
        if campaign
          new_campaign = campaign.dup
          new_campaign.save
          new_campaign.update_attributes(user_id: user.id)
          new_campaign_detail = campaign.campaign_detail.dup
          new_campaign_detail.save
          new_campaign_detail.update_attributes(campaign_id: new_campaign.id)
          save_test_channels(user,campaign,params) if user
          new_campaign
        end
      else
        create_power_share(user,params)
      end
    end

    def self.save_test_channels(user,campaign,params)
      CampaignChannel.save_channels(campaign,params)
      approved_campaigns(params,user,campaign)
    end

    def self.campaign_params(user)
      {
          social_channels: user.user_social_channels.where(active: true).map(&:id),
          mobile_channels: user.user_mobile_channels.where(active: true).map(&:id),
          location_channels: user.user_location_channels.map(&:id),
          schedule_on: Time.now,
          share_now: true
      }
    end
  end
end