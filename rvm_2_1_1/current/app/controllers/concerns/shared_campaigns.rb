module SharedCampaigns
  extend ActiveSupport::Concern
  included do

    def beacon_campaigns
      beacon = Beacon.where(uid: params[:uid]).first
      location_channel = UserLocationChannel.where(channel_id: beacon.id, channel_type: beacon.class.name)[0]
      user_channel = UserChannel.where(channel_type: location_channel.class.name, channel_id: location_channel.id)[0]
      campaign_ids = CampaignChannel.where(user_channel_id: user_channel.id).map(&:campaign_id)
      queued_list = Delayed::Job.where(user_id: beacon.user_id, failed_at: nil).map(&:campaign_id)
      campaigns = Campaign.where(id: campaign_ids - queued_list, is_archived: false)
      collection = []
      campaigns.each do |campaign|
        json = {}
        json["campaign_id"] = campaign.id
        json["campaign_data"] = campaign.campaign_detail ? JSON.parse(campaign.campaign_detail.campaign_data) : {}
        collection << json
      end
      render :json => success({ resCode: 1001, resMessage: "SUCCESS"}, HashConverter.to_camel_case(collection))
    end
  end
end