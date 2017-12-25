class CampaignSmsJob < Struct.new(:file_name, :msg, :sms_channel, :campaign)
  require 'rest_client'
  def perform
    status = RestClient.post('http://enterprise.smsgupshup.com/GatewayAPI/rest', :xlsFile => File.new(file_name), :method => "xlsUpload", :userid => ENV["GUPSHUP_USERID"], :password => ENV["GUPSHUP_PASSWORD"], :msg => msg, :msg_type => "TEXT", :version => "1.1", :auth_scheme => "PLAIN", :filetype => "csv")
    if status.split("|").first.strip == "success"
      transaction_id = status.split("|").last.scan(/\d+/).first
      CampaignChannel.mobile_post_info(transaction_id, sms_channel,campaign,ShareMedium._id("Mobile"))
    end
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
