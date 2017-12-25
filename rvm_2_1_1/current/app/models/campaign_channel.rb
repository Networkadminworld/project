class CampaignChannel < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :user_channel
  belongs_to :share_medium, foreign_key: :share_medium_id

  def self.save_channels(campaign,params)
    social(campaign,params)
    mobile(campaign,params)
    location(campaign,params)
  end

  def self.save_post_info(post_id, social,campaign,share_medium_id)
    user_channel = UserChannel.where(channel_id: social.id, channel_type: "UserSocialChannel").first
    camp_channel = CampaignChannel.where(campaign_id: campaign.id,user_channel_id: user_channel.id, share_medium_id: share_medium_id).first
    camp_channel.update_attributes(post_id: post_id, connections: social.connections)
  end

  def self.mobile_post_info(post_id, mobile,campaign,share_medium_id)
    user_channel = UserChannel.where(channel_id: mobile.id, channel_type: "UserMobileChannel").first
    camp_channel = CampaignChannel.where(campaign_id: campaign.id, user_channel_id: user_channel.id, share_medium_id: share_medium_id).first
    camp_channel.update_attributes(post_id: post_id)
  end

  private

  def self.social(campaign,params)
    user_social_channels = UserChannel.where(user_id: campaign.user_id, channel_type: "UserSocialChannel").where(channel_id: parse_request(params[:social_channels]))
    user_social_channels.each do |social_channel|
      create(campaign_id: campaign.id, user_channel_id: social_channel.id, share_medium_id: ShareMedium._id("Social"))
    end
  end

  def self.mobile(campaign,params)
    user_mobile_channels = UserChannel.where(user_id: campaign.user_id, channel_type: "UserMobileChannel").where(channel_id: parse_request(params[:mobile_channels]))
    user_mobile_channels.each do |mobile_channel|
      create(campaign_id: campaign.id, user_channel_id: mobile_channel.id, share_medium_id: ShareMedium._id("Mobile"))
    end
  end

  def self.location(campaign,params)
    user_location_channels = UserChannel.where(user_id: campaign.user_id, channel_type: "UserLocationChannel").where(channel_id: parse_request(params[:location_channels]))
    user_location_channels.each do |location_channel|
      create(campaign_id: campaign.id, user_channel_id: location_channel.id, share_medium_id: ShareMedium._id("In-location"))
    end
  end

  def self.parse_request(channels)
    channels.is_a?(String) ? JSON.parse(channels) : channels
  end
end