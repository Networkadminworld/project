class I18nCampaignSmsJob < Struct.new(:file_name, :msg, :sms_channel, :campaign)
  require 'rest_client'
  require 'csv'

  def perform
    phone_numbers = []
    CSV.foreach(file_name, :headers => true, :header_converters => :symbol, :skip_blanks => true, :encoding => 'ISO-8859-1', :converters => :all) do |row|
      hash_val = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
      phone_numbers << hash_val[:phone]
    end
    response = {:sid =>  0 }.stringify_keys!
    phone_numbers.each do |number|
      begin
        client = Twilio::REST::Client.new ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"]
        account = client.account
        response = account.sms.messages.create({:from => ENV["SMS_NUM"], :to => "+#{number}", :body => msg })
      rescue => e
        TWILIO_LOGGER.info("Error(sms): #{e}")
      end
    end
    CampaignChannel.mobile_post_info(response, sms_channel,campaign,ShareMedium._id("Mobile"))
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