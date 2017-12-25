module SystemAlertLog
  extend ActiveSupport::Concern
  included do

    def self.system_alerts(params,event,user)
      post_input_params = campaign_post_params(params,event,event.alert_config,user)
      event_posts,event_posts_recipients = trigger_post_event(event,user,post_input_params,params)
      params.merge!({:event_posts => event_posts,
                     :event_posts_recipients => event_posts_recipients,
                     :event_message => post_input_params[:biz_app_message],
                     :event_sms_message => post_input_params[:sms_message]})
      create! alert_event_id: event.id, user_id: event.user_id, event_params: event_post_params(params)
      logs = AlertLog.where(user_id: event.user_id).map(&:id)
      Delayed::Worker.logger.debug("UPDATED ALERT_LOG: #{logs}")
    end
  end
end