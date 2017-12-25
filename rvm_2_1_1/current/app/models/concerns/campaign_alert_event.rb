module CampaignAlertEvent
  extend ActiveSupport::Concern
  included do

    def send_business_alert
      service_user = User.where(id: self.service_user_id).first
      service_user_name = service_user.blank? ? "" : service_user.try(:first_name) + ' ' + service_user.try(:last_name)
      params = {
          :event_name => "CAMPAIGN_WAITING_FOR_APPROVAL",
          :user_id => self.user_id,
          :event_params => {
              :campaign_id => self.id,
              :callback_url => "#{ENV['CUSTOM_URL']}/#/campaigns/index?src=campaign&cid=#{self.campaign_uuid}",
              :place_holders => {
                  "{campaign_name}" => self.label,
                  "{service_user_name}" => service_user_name
              },
              :callback_app => {
                  :response_id => self.id,
                  :module => "CAMPAIGNS"
              },
              :post_state => 'APPROVAL'
          }
      }
      AlertLog.send_event(params)
    end

    def send_approved_alert
      AlertLog.send_event(before_alert_params(self,'CAMPAIGN_APPROVED','APPROVED'))
    end

    def send_rejected_alert
      AlertLog.send_event(before_alert_params(self,'CAMPAIGN_REJECTED','REJECTED'))
    end

    def before_alert_params(campaign,event_name,status)
      {
          :event_name => event_name,
          :user_id => campaign.user_id,
          :service_user_id => campaign.service_user_id,
          :event_params => {
              :campaign_id => campaign.id,
              :callback_url => "#{ENV['CUSTOM_URL']}/#/campaigns/index?src=campaign&cid=#{campaign.campaign_uuid}",
              :place_holders => {
                  "{campaign_name}" => campaign.label,
                  "{status}" => status
              },
              :callback_app => {
                  :response_id => campaign.id,
                  :module => "CAMPAIGNS"
              }
          }
      }
    end
  end
end