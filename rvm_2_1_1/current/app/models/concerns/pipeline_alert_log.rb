module PipelineAlertLog
  extend ActiveSupport::Concern
  included do

    def self.pipeline_events(params,event,user)
      if event.name == 'REMINDER_APPOINTMENT'
        send_activity_reminder(params)
      else
        post_input_params = post_params(params,event,event.alert_config,user)
        event_posts,event_posts_recipients = trigger_post_event(event,user,post_input_params,params)
        params.merge!({:event_posts => event_posts,
                       :event_posts_recipients => event_posts_recipients,
                       :event_message => post_input_params[:biz_app_message],
                       :event_sms_message => post_input_params[:sms_message]})
        create! alert_event_id: event.id, user_id: user.id, event_params: event_post_params(params)
      end
    end

    def self.post_params(params,event,config,user)
      email_addresses = []
      sms_receivers = []
      config.email["recipients"] && config.email["recipients"].each { |list| email_addresses << list["text"] }
      config.sms["recipients"] && config.sms["recipients"].each { |list| sms_receivers << list["text"] }
      post_request_info = {
          :email_message => config.email["message"] ? email_message_parser(config.email["message"],params,false) : email_message_parser(APP_MSG["pipeline"][event.name],params,false),
          :sms_message => config.sms["message"] ? sms_message_parser(config.sms["message"],params,false) : sms_message_parser(APP_MSG["pipeline"][event.name],params,false),
          :biz_app_message => config.business_app["message"] ? app_message_parser(config.business_app["message"],params,false) : app_message_parser(APP_MSG["pipeline"][event.name],params,false),
          :subject => config.email["subject"] ? parse_subject(config.email["subject"], params) : "Inquirly Alert",
          :email_recipients => email_addresses.blank? ? [user.email] : email_addresses,
          :sms_recipients => sms_receivers.blank? ? [user.mobile] : sms_receivers,
          :app_recipients => user && user.devices ? user.devices.map(&:device_id).reject(&:nil?).uniq : [],
          :first_name => params[:event_params][:alert_recipients] ? params[:event_params][:alert_recipients][:customers][:first_name] : '',
          :phone => params[:event_params][:alert_recipients] ? params[:event_params][:alert_recipients][:customers][:phone] : '',
          :address => params[:event_params][:alert_recipients] ? params[:event_params][:alert_recipients][:customers][:address] : '',
          :item_code => params[:event_params][:item_code],
          :item_price => params[:event_params][:item_price],
          :item_image_src => params[:event_params][:item_image_src],
          :item_name => params[:event_params][:item_name],
          :app_module => params[:event_params][:callback_app][:module],
          :post_type => params[:event_params][:callback_app][:type],
          :post_id => params[:event_params][:callback_app][:response_id],
          :state => params[:event_params][:callback_app][:state]
      }
      post_request_info
    end


    def self.send_activity_reminder(params)
      user = User.where(id: params["alert_recipients"]["user_ids"]).first
      if user
        post_request_info = {
            :email_recipients => [{:name => user.try(:first_name) || '', :email => user.email }],
            :day => Time.now.strftime("%A %b %d %Y").upcase,
            :activities => add_activity_icons(params["event_params"]["activities"])
        }
        send_activity_email(post_request_info)
      end
    end

    def self.add_activity_icons(activities)
      activities.each do |activity|
        if activity["action_type"] == 'MEETING'
          activity["icon_src"] = 'http://i.imgur.com/uX0rqEp.png'
        elsif activity["action_type"] == 'CALL'
          activity["icon_src"] = 'http://i.imgur.com/SBmgYaN.png'
        elsif activity["action_type"] == "DEMO"
          activity["icon_src"] = 'http://i.imgur.com/4Mam2jm.png'
        else
          activity["icon_src"] = 'http://i.imgur.com/3ZZQfZH.png'
        end
      end
      activities
    end
  end
end