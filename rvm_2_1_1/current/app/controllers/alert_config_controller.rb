class AlertConfigController < ApplicationController
  respond_to :json
  before_filter :authenticate_user_web_api, except: [:send_alerts, :create_alert_event, :delete_alert_event]

  def index
    render :json => AlertEvent.fetch_user_events(current_user)
  end

  def change_event_status
     render :json => AlertEvent.change_status(params,current_user)
  end

  def change_channel_status
    render :json => AlertEventChannel.change_status(params)
  end

  def alerts
    render :json => AlertLog.all_active_alerts(current_user)
  end

  def send_alerts
    begin
      AlertLog.send_event(params)
      response = { status: 200, success: 'Alert set successfully'}
    rescue Exception => e
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  def update_view_status
    render :json => AlertLog.update_status(params)
  end

  def update_alert_config
    render :json => AlertConfig.update_config(params)
  end

  def create_alert_event
    begin
      response = AlertEvent.create_event(params)
    rescue Exception => e
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  def update_alert_event
    render :json => AlertEvent.update_event(params)
  end

  def delete_alert_event
    begin
      event = AlertEvent.delete_event(params)
      response = { status: 200, event: event, success: 'Alert event deleted successfully' }
    rescue Exception => e
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  def get_alert_placeholders
    render json: {status: 200, placeholders: AlertConfig.fetch_placeholders(params)}
  end

end