module CampaignAlertLog
  extend ActiveSupport::Concern
  included do

    def self.campaign_events(params,event,user)
      post_input_params = campaign_post_params(params,event,event.alert_config,user)
      logs =  where(alert_event_id: event.id, user_id: event.user_id)
      if event.is_default && event.name != "CAMPAIGN_WAITING_FOR_APPROVAL"
        if logs.blank?
          Delayed::Worker.logger.debug("CAMPAIGN ALERT LOG IF BLOCK: #{logs}")
          campaign_alert(params,event,user,post_input_params)
        else
          already_alerted_campaigns = []
          logs.each do |log|
            already_alerted_campaigns << log.event_params[:params][:campaign_id] if log.event_params[:params]
          end
          Delayed::Worker.logger.debug("CAMPAIGN ALERT LOG ELSE: #{already_alerted_campaigns}")
          campaign_alert(params,event,user,post_input_params) unless already_alerted_campaigns.reject(&:blank?).include?(params[:event_params][:campaign_id])
        end
      else
        campaign_alert(params,event,user,post_input_params)
      end
    end

    def self.campaign_service_events(params,event,user)
      post_input_params = service_alert_params(params,event,event.alert_config)
      event_posts,event_posts_recipients = trigger_post_event(event,user,post_input_params,params)
      params.merge!({:event_posts => event_posts,
                     :event_posts_recipients => event_posts_recipients,
                     :event_message => post_input_params[:biz_app_message],
                     :event_sms_message => post_input_params[:sms_message]})
      AlertLog.create! alert_event_id: event.id, user_id: params[:service_user_id], event_params: event_post_params(params)
    end

    def self.campaign_alert(params,event,user,post_input_params)
      event_posts,event_posts_recipients = trigger_post_event(event,user,post_input_params,params)
      params.merge!({:event_posts => event_posts,
                     :event_posts_recipients => event_posts_recipients,
                     :event_message => post_input_params[:biz_app_message],
                     :event_sms_message => post_input_params[:sms_message]})
      create! alert_event_id: event.id, user_id: event.user_id, event_params: event_post_params(params)
    end

    def self.campaign_post_params(params,event,config,user)
      email_addresses = []
      sms_receivers = []
      config && config.email["recipients"] && config.email["recipients"].each { |list| email_addresses << list["text"] }
      config && config.sms["recipients"] && config.sms["recipients"].each { |list| sms_receivers << list["text"] }
      post_request_info = {
          :email_message => config && config.email["message"] ? email_message_parser(config.email["message"],params,false) : email_message_parser(APP_MSG["campaign"][event.name],params,false) || 'You have received a new feedback',
          :sms_message => config && config.sms["message"] ? sms_message_parser(config.sms["message"],params,false) : sms_message_parser(APP_MSG["campaign"][event.name],params,false) || 'You have received a new feedback',
          :biz_app_message => config && config.business_app["message"] ? app_message_parser(config.business_app["message"],params,false) : app_message_parser(APP_MSG["campaign"][event.name],params,false) || 'You have received a new feedback',
          :subject => config && config.email["subject"] ? parse_subject(config.email["subject"],params) : "Inquirly Alert",
          :email_recipients => email_addresses.blank? ? [user.email] : email_addresses,
          :sms_recipients => sms_receivers.blank? ? [user.mobile] : sms_receivers,
          :app_recipients => user && user.devices ? user.devices.map(&:device_id).reject(&:nil?).uniq : [],
          :app_module => params[:event_params][:callback_app][:module],
          :post_id => params[:event_params][:callback_app][:response_id],
          :state => params[:event_params][:post_state]
      }
      post_request_info
    end

    def self.service_alert_params(params,event,config)
      email_addresses = []
      sms_receivers = []
      service_user = User.where(id: params[:service_user_id]).first
      config && config.email["recipients"] && config.email["recipients"].each { |list| email_addresses << list["text"] }
      config && config.sms["recipients"] && config.sms["recipients"].each { |list| sms_receivers << list["text"] }
      post_request_info = {
          :email_message => config && config.email["message"] ? email_message_parser(config.email["message"],params,false) : email_message_parser(APP_MSG["campaign"][event.name],params,false) || 'You have received a new feedback',
          :sms_message => config && config.sms["message"] ? sms_message_parser(config.sms["message"],params,false) : sms_message_parser(APP_MSG["campaign"][event.name],params,false) || 'You have received a new feedback',
          :biz_app_message => config && config.business_app["message"] ? app_message_parser(config.business_app["message"],params,false) : app_message_parser(APP_MSG["campaign"][event.name],params,false) || 'You have received a new feedback',
          :subject => config && config.email["subject"] ? parse_subject(config.email["subject"],params) : "Inquirly Alert",
          :email_recipients => email_addresses.blank? ? [service_user.email] : email_addresses,
          :sms_recipients => sms_receivers.blank? ? [service_user.mobile] : sms_receivers,
          :app_recipients => service_user && service_user.devices ? service_user.devices.map(&:device_id).reject(&:nil?).uniq : [],
          :app_module => params[:event_params][:callback_app][:module],
          :post_id => params[:event_params][:callback_app][:response_id],
          :state => params[:event_params][:post_state]
      }
      post_request_info
    end
  end
end