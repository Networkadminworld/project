module InLocationShare
  extend ActiveSupport::Concern
  included do

    def self.in_location_process(params,user,campaign)
      beacon_process(params,user,campaign) if campaign.qr_code_channels.count > 0
      qr_code_process(params,user,campaign) if campaign.beacon_channels.count > 0
      opinify_process(params,user,campaign) if campaign.opinify_channels.count > 0
    end

    def self.beacon_process(params,user,campaign)
      BitLyService.new.create_shorten_url('QrCode',campaign) if campaign.long_url
      if params[:share_now]
        QrCodeCampaign.create_qr_campaigns(campaign.qr_code_channels.map(&:channel_id),campaign)
      else
        Delayed::Job.enqueue InLocationJob.new(campaign, 'Qrcode'), priority: 2, run_at: params[:schedule_on], campaign_id: campaign.id, user_id: user.id, share_now: params[:share_now]
      end
    end

    def self.qr_code_process(params,user,campaign)
      BitLyService.new.create_shorten_url('Beacon',campaign) if campaign.long_url
      Delayed::Job.enqueue InLocationJob.new(campaign, 'Beacon'), priority: 2, run_at: params[:schedule_on], campaign_id: campaign.id, user_id: user.id, share_now: params[:share_now] unless params[:share_now]
    end

    def self.opinify_process(params,user,campaign)
      BitLyService.new.create_shorten_url('opinify',campaign) if campaign.long_url
      Delayed::Job.enqueue InLocationJob.new(campaign, 'Opinify'), priority: 2, run_at: params[:schedule_on], campaign_id: campaign.id, user_id: user.id, share_now: params[:share_now] unless params[:share_now]
    end
  end
end