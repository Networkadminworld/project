require 'rest_client'
module CampaignInfo
  extend ActiveSupport::Concern
  included do

    def mobile_channels
      self.campaign_channels.where(share_medium_id: ShareMedium._id("Mobile"))
    end

    def social_channels
      self.campaign_channels.where(share_medium_id: ShareMedium._id("Social"))
    end

    def email_channels
      UserMobileChannel.where(id: user_mobile_channels, channel: "email")
    end

    def sms_channels
      UserMobileChannel.where(id: user_mobile_channels, channel: "sms")
    end

    def fb_channels
      UserSocialChannel.where(id: user_social_channels, channel: "facebook")
    end

    def tw_channels
      UserSocialChannel.where(id: user_social_channels, channel: "twitter")
    end

    def ln_channels
      UserSocialChannel.where(id: user_social_channels, channel: "linkedin")
    end

    def opinify_channels
      UserMobileChannel.where(id: user_mobile_channels, channel: "opinify")
    end

    def user_social_channels
      UserChannel.where(id: self.social_channels.map(&:user_channel_id), channel_type: "UserSocialChannel").map(&:channel_id)
    end

    def user_mobile_channels
      UserChannel.where(id: self.mobile_channels.map(&:user_channel_id),channel_type: "UserMobileChannel").map(&:channel_id)
    end

    def user_location_channels
      UserChannel.where(id: self.location_channels.map(&:user_channel_id),channel_type: "UserLocationChannel").map(&:channel_id)
    end

    def location_channels
      self.campaign_channels.where(share_medium_id: ShareMedium._id("In-location"))
    end

    def qr_code_channels
      UserLocationChannel.where(id: user_location_channels,channel_type: "QrCode")
    end

    def beacon_channels
      UserLocationChannel.where(id: user_location_channels,channel_type: "Beacon")
    end

    def campaign_status
      scheduled_campaign = Delayed::Job.where(campaign_id: self.id).first
      scheduled_campaign ? scheduled_campaign.share_now : false
    end

    def short_url
      detail = self.campaign_detail
      JSON.parse(detail.campaign_data)["shorten_url"] if detail
    end

    def long_url
      detail = self.campaign_detail
      if detail && JSON.parse(detail.campaign_data)["shorten_url"]
        JSON.parse(RestClient.post ENV['SHORTEN_LONG_URL_DOMAIN'], {url: JSON.parse(detail.campaign_data)["shorten_url"], secret: ENV['SHORTEN_SECRET']}.to_json, :content_type => 'application/json')["long_url"]
      end
    end

    def self.channel_list(user,params)
      list = []
      campaign = where(id: params[:campaign_id],user_id: user.id).first
      accounts = campaign.email_channels + campaign.sms_channels + campaign.fb_channels + campaign.tw_channels + campaign.ln_channels +
          campaign.opinify_channels + campaign.qr_code_channels + campaign.beacon_channels
      accounts.each do |account|
        if account.class.model_name.name == 'UserMobileChannel'
          list << account.get_mobile_channel
        elsif account.class.model_name.name == 'UserSocialChannel'
          list << account.get_social_channel
        else
          list << account.get_location_channel
        end
      end
      list
    end

    def self.update_campaign_status(params)
      campaign = where(id: params[:inq_campaign_id], user_id: params[:publisher_id], service_user_id: params[:servicer_id]).first
      if campaign
        campaign.update_attributes(status: params[:state])
        case params[:state]
          when 'APPROVED'
            user = User.where(id: campaign.user_id).first
            params = { schedule_on: params[:schedule_on], share_now: params[:share_now], is_api_request: params[:is_api_request], state: params[:state]}
            Delayed::Job.where(campaign_id: campaign.id).destroy_all
            approved_campaigns(params,user,campaign)
            campaign.send_approved_alert
          when 'REJECTED'
            Delayed::Job.where(campaign_id: campaign.id).destroy_all
            Revision.save_campaign_revision(params)
            campaign.send_rejected_alert
          else
        end
        update_inq_campaign_state(campaign, params[:state]) if params[:is_api_request]
      end
    end

    def update_revisions
      revisions = Revision.where(campaign_id: self.id, is_updated: false)
      revisions.update_all(is_updated: true) unless revisions.blank?
    end

    def self.update_inq_campaign_state(campaign,state)
      inq_campaign = InqCampaign.where(inq_campaign_id: campaign.id).first
      inq_campaign.update_attributes(approval_status: state) if inq_campaign
    end
  end
end