module PipelineConsumerAlertLog
  extend ActiveSupport::Concern
  included do

    def self.pipeline_consumer_events(params,event,user)
      post_input_params = pipeline_post_params(params,event,event.alert_config)
      event_posts,event_posts_recipients = trigger_post_event(event,user,post_input_params,params)
      params.merge!({:event_posts => event_posts,
                     :event_posts_recipients => event_posts_recipients,
                     :event_message => post_input_params[:consumer_app_message],
                     :event_sms_message => post_input_params[:sms_message]})
      create! alert_event_id: event.id, user_id: user.id, event_params: event_post_params(params)
    end

    def self.pipeline_post_params(params,event,config)
      post_request_info = {
          :email_message => config.email["message"] ? email_message_parser(config.email["message"],params,true) : email_message_parser(APP_MSG["pipeline"][event.name],params,true),
          :sms_message => config.sms["message"] ? sms_message_parser(config.sms["message"],params,true) : sms_message_parser(APP_MSG["pipeline"][event.name],params,true),
          :consumer_app_message => config.consumer_app["message"] ? app_message_parser(config.consumer_app["message"],params,true) : app_message_parser(APP_MSG["pipeline"][event.name],params,true),
          :subject => config.email["subject"] ? parse_subject(config.email["subject"],params) : "Inquirly Alert",
          :email_recipients => [params[:event_params][:alert_recipients][:customers][:email]],
          :sms_recipients => [params[:event_params][:alert_recipients][:customers][:phone]],
          :first_name => params[:event_params][:alert_recipients][:customers][:first_name],
          :phone => params[:event_params][:alert_recipients][:customers][:phone],
          :address => params[:event_params][:alert_recipients][:customers][:address],
          :item_code => params[:event_params][:item_code],
          :item_price => params[:event_params][:item_price],
          :item_image_src => params[:event_params][:item_image_src],
          :item_name => params[:event_params][:item_name],
      }
      post_request_info
    end
  end
end