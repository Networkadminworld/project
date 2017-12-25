module ServiceUserAlert
  extend ActiveSupport::Concern
  included do

    def self.service_user_alert_events(params,event,user)
      company_id = user.parent_id == 0 ? user.company.try(:id) : user.client.company.try(:id)
      user_ids = ExecutiveBusinessMapping.where(company_id: company_id).map(&:user_id)
      email_addresses,sms_receivers,app_recipients = recipient_details(user_ids)
      if event && event.alert.try(:name) == 'pipeline'
        post_input_params = pipeline_alert_params(params,event,email_addresses,sms_receivers,app_recipients)
        event_posts,event_posts_recipients = trigger_post_event(event,user,post_input_params,params,true)
        params.merge!({:event_posts => event_posts,:event_posts_recipients => event_posts_recipients,:event_message => post_input_params[:biz_app_message],:event_sms_message => post_input_params[:sms_message]})
        user_ids.each do |user_id|
          create! alert_event_id: event.id, user_id: user_id, event_params: event_post_params(params)
        end
      elsif event && event.alert.try(:name) == 'campaigns'
        trigger_campaign_alert(user,event,user_ids,params) unless ['CAMPAIGN_WAITING_FOR_APPROVAL','CAMPAIGN_APPROVED','CAMPAIGN_REJECTED'].include?(event.name)
      end
    end

    def self.pipeline_alert_params(params,event,email_addresses,sms_receivers,app_recipients)
      config = event.alert_config
      {
        :email_message => config.email["message"] ? email_message_parser(config.email["message"],params,false) : email_message_parser(APP_MSG["pipeline"][event.name],params,false),
        :sms_message => config.sms["message"] ? sms_message_parser(config.sms["message"],params,false) : sms_message_parser(APP_MSG["pipeline"][event.name],params,false),
        :biz_app_message => config.business_app["message"] ? app_message_parser(config.business_app["message"],params,false) : app_message_parser(APP_MSG["pipeline"][event.name],params,false),
        :subject => config.email["subject"] ? parse_subject(config.email["subject"], params) : "Inquirly Alert",
        :email_recipients => email_addresses,
        :sms_recipients => sms_receivers,
        :app_recipients => app_recipients,
        :first_name => params[:event_params][:alert_recipients] ? params[:event_params][:alert_recipients][:customers][:first_name] : '',
        :phone => params[:event_params][:alert_recipients] ? params[:event_params][:alert_recipients][:customers][:phone] : '',
        :address => params[:event_params][:alert_recipients] ? params[:event_params][:alert_recipients][:customers][:address] : '',
        :item_code => params[:event_params][:item_code],
        :item_price => params[:event_params][:item_price],
        :item_image_src => params[:event_params][:item_image_src],
        :item_name => params[:event_params][:item_name],
        :app_module => params[:event_params][:callback_app][:module],
        :post_id => params[:event_params][:callback_app][:response_id]
      }
    end

    def self.campaign_alert_params(params,event,email_addresses,sms_receivers,app_recipients)
      config = event.alert_config
      {
        :email_message => config.email["message"] ? email_message_parser(config.email["message"],params,false) : email_message_parser(APP_MSG["campaign"][event.name],params,false),
        :sms_message => config.sms["message"] ? sms_message_parser(config.sms["message"],params,false) : sms_message_parser(APP_MSG["campaign"][event.name],params,false),
        :biz_app_message => config.business_app["message"] ? app_message_parser(config.business_app["message"],params,false) : app_message_parser(APP_MSG["campaign"][event.name],params,false),
        :subject => config.email["subject"] ? parse_subject(config.email["subject"],params) : "Inquirly Alert",
        :email_recipients => email_addresses,
        :sms_recipients => sms_receivers,
        :app_recipients => app_recipients,
        :app_module => params[:event_params][:callback_app][:module],
        :post_id => params[:event_params][:callback_app][:response_id],
      }
    end

    def self.recipient_details(user_ids)
      email_addresses = []
      sms_receivers = []
      app_recipients = []
      User.where(id: user_ids).each do |user|
        email_addresses << user.email
        sms_receivers << user.mobile
        app_recipients << user.devices ? user.devices.map(&:device_id).reject(&:nil?).reject(&:blank?).uniq : ''
      end
      [email_addresses,sms_receivers,app_recipients.reject(&:blank?).uniq]
    end

    def self.trigger_campaign_alert(user,event,user_ids,params)
      user_ids.each do |user_id|
        logs =  where(alert_event_id: event.id, user_id: user_id)
        campaign_ids = Campaign.where(service_user_id:  user_id).map(&:id)
        if campaign_ids.include?(params[:event_params][:campaign_id])
          if event.is_default
            if logs.blank?
              Delayed::Worker.logger.debug("SERVICE ALERT LOG IF: #{logs}")
              trigger_alert(user,user_id,params,event)
            else
              already_alerted_campaigns = []
              logs.each do |log|
                already_alerted_campaigns << log.event_params[:params][:campaign_id] if log.event_params[:params]
              end
              Delayed::Worker.logger.debug("SERVICE ALERT ELSE: #{already_alerted_campaigns}")
              trigger_alert(user,user_id,params,event) unless already_alerted_campaigns.reject(&:blank?).include?(params[:event_params][:campaign_id])
            end
          else
            trigger_alert(user,user_id,params,event)
          end
        end
      end
    end

    def self.trigger_alert(user,user_id,params,event)
      email_addresses,sms_receivers,app_recipients = recipient_details([user_id])
      post_input_params = campaign_alert_params(params,event,email_addresses,sms_receivers,app_recipients)
      event_posts,event_posts_recipients = trigger_post_event(event,user,post_input_params,params,true)
      params.merge!({:event_posts => event_posts,:event_posts_recipients => event_posts_recipients,:event_message => post_input_params[:email_message],:event_sms_message => post_input_params[:sms_message]})
      create! alert_event_id: event.id, user_id: user_id, event_params: event_post_params(params)
      logs = AlertLog.where(user_id: event.user_id).map(&:id)
      Delayed::Worker.logger.debug("UPDATED ALERT_LOG FROM SERVICE USER: #{logs}")
    end
  end
end