class AlertConfig < ActiveRecord::Base
  belongs_to :alert_event

  serialize :email, Hash
  serialize :sms, Hash
  serialize :business_app, Hash
  serialize :consumer_app, Hash

  def self.update_config(params)
    config = where(alert_event_id: params[:event_id]).first
    if config
      if params[:email]
        config.email["recipients"] = params[:email][:recipients]
        config.email["subject"] = params[:email][:subject]
        config.email["message"] = params[:email][:message]
      end
      if params[:sms]
        config.sms["recipients"] = params[:sms][:recipients]
        config.sms["message"] = params[:sms][:message]
      end
      config.business_app["message"] = params[:business_app][:message] if params[:business_app]
      config.consumer_app["message"] = params[:consumer_app][:message] if params[:consumer_app]
      config.is_html = params[:is_html] if params[:is_html].present?
      config.save
    else
      config = create(alert_event_id: params[:event_id],email: params[:email], sms: params[:sms], business_app: params[:business_app], is_html: params[:is_html])
    end
    config
  end

  def self.fetch_placeholders(params)
    config = where(alert_event_id: params[:alert_id]).first
    config ? config.email["placeholders"] : []
  end
end