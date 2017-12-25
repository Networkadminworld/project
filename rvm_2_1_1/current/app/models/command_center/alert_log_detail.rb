module CommandCenter
  class AlertLogDetail
    attr_reader :client_user_id, :service_user_id

    def initialize(client_user_id, service_user_id,limit,offset)
      @client_user = User.where(id: client_user_id).first
      @service_user = User.where(id: service_user_id).first
      @limit = limit
      @offset = offset
    end

    def results
      @client_user.present? && @service_user.nil? ? client_user_alerts : service_user_alerts
    end

    def client_user_alerts
      fetch_logs(AlertLog.where(user_id: @client_user.id).limit(@limit).offset(@offset).order(:id => :desc))
    end

    def service_user_alerts
      fetch_logs(AlertLog.where(user_id: @service_user.id, alert_event_id: @client_user.alert_events.map(&:id)).limit(@limit).offset(@offset).order(:id => :desc))
    end

    def fetch_logs(logs)
      list = []
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
      { alerts: list, alert_count: logs.where(is_viewed: nil).count}
    end
  end
end