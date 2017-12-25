class AlertLog < ActiveRecord::Base
  include EventChannelService
  include PostMessageParser
  include SystemAlertLog
  include PipelineAlertLog
  include CampaignAlertLog
  include PipelineConsumerAlertLog
  include ServiceUserAlert

  after_create :trigger_event

  serialize :event_params, Hash

  def self.all_active_alerts(user)
    list = []
    logs = where(user_id: user.id).order(:id => :desc)
    logs.each do |log|
      obj = {
          id: log.id,
          event_message: log.event_params[:event_message],
          alert_type: log.event_name,
          is_viewed: log.is_viewed,
          alert_sent_on: log.event_params[:event_sent_on]
      }
      list << obj
    end
    {alerts: list, alert_count: user.alert_logs.where(is_viewed: nil).count}
  end

  def self.send_event(params)
    event,user = find_alert_event(params)
    if event && event.alert_type.try(:name) == 'business'
      if event && event.is_set_on && event.alert.try(:name) == 'pipeline'
        pipeline_events(params,event,user)
      elsif event && event.is_set_on && event.alert.try(:name) == 'campaigns'
        ["CAMPAIGN_APPROVED", "CAMPAIGN_REJECTED"].include?(event.name) ? campaign_service_events(params,event,user) : campaign_events(params,event,user)
      elsif event && event.is_set_on && event.alert.try(:name) == 'system'
        system_alerts(params,event,user)
      end
      service_user_alert_events(params,event,user)
    elsif event && event.alert_type.try(:name) == 'consumer'
      pipeline_consumer_events(params,event,user)
    end
  end

  def self.find_alert_event(params)
    if params[:alert_id].present?
      decoded_alert_id = Base64.decode64(params[:alert_id]).split("_")
      user = User.where(id: decoded_alert_id[1].to_i).first
      event = AlertEvent.where(id: decoded_alert_id[3].to_i, user_id: decoded_alert_id[1].to_i).first
    else
      user = User.where(id: params[:user_id]).first
      event = AlertEvent.where(name: params[:event_name].upcase.strip, user_id: user.try(:id)).first
    end
    [event,user]
  end

  def self.event_post_params(params)
    {
        :event_posts => params[:event_posts],
        :event_posts_recipients => params[:event_posts_recipients],
        :event_message => params[:event_message],
        :event_sms_message => params[:event_sms_message],
        :params => params[:event_params],
        :event_sent_on => Time.now
    }
  end

  def self.is_sms_channel_on?(channels)
    state = false
    channels.each do |channel|
      state if channel[:name] == 'sms' && channel[:is_active] == true
    end
    state
  end

  def self.update_status(params)
    log = where(id: params[:id]).first
    log.update_attributes(is_viewed: true) unless log.is_viewed
  end

  def update_redirect_path
    message = self.event_params[:event_message]
    if message.include? 'VIEW POST'
      message = message.gsub("VIEW POST","<a data-ng-click='viewPostRedirect(\"#{self.id}\",\"#{self.event_name}\",\"#{self.event_params[:params][:callback_url]}\")'>VIEW POST</a>")
      self.event_params[:event_message] = message
      self.save
    end
  end

  def is_business_alert?
    return true if self.event_params[:event_posts].blank? && AlertEvent.where(id: self.alert_event_id, alert_type_id: AlertType.where(name: "consumer").first.try(:id)).blank?
    self.event_params[:event_posts] && self.event_params[:event_posts].first[:type] == 'business'
  end

  def event_name
    Alert.where(id: AlertEvent.where(id: self.alert_event_id).first.try(:alert_id)).first.try(:name)
  end

  def trigger_event
    self.update_redirect_path
    obj = { id: self.id, event_message: self.event_params[:event_message],alert_type: self.event_name,is_viewed: self.is_viewed,alert_sent_on: self.event_params[:event_sent_on], user_id: self.user_id}
    WebsocketRails[:posts].trigger('posts', obj) if self.is_business_alert?
  end
end