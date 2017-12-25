class AlertEvent < ActiveRecord::Base
  has_many :alert_event_channels, dependent: :destroy
  has_one :alert_config, dependent: :destroy
  belongs_to :alert_type
  belongs_to :alert

  validates :name, :uniqueness => {:scope => :user_id, :message => "Event already exists."}

  def self.fetch_user_events(user)
    list = {}
    list["alert_events"] = []
    alert_ids = Alert.where.not(name: "system").map(&:id)
    events = where(user_id: user.id, alert_id: alert_ids).where.not(name: ["CAMPAIGN_APPROVED","CAMPAIGN_REJECTED","REMINDER_APPOINTMENT"]).order(id: :asc)
    events.each do |event|
      list["alert_events"] << { id: event.id, alert_id: Base64.encode64("u_#{event.user_id}_a_#{event.id}"),name: event.is_default ? APP_MSG["event_name"][event.name] : event.name, is_set: event.is_set_on, type: event.alert.try(:name),
                                is_business_event: event.alert_type.try(:name) == "business",alert_config: event.alert_config, is_default: event.is_default, user_id: event.user_id,
                                event_channels: event.alert_event_channels.order(id: :asc).collect{ |i| i.as_json(:except => [:alert_event_id, :alert_channel_id, :created_at, :updated_at], :methods => [:channel_name])} }
    end
    list
  end

  def self.create_event(params)
    event = new(name: params[:event_name].upcase, is_default: false, is_set_on: true,alert_id: Alert.find_id(params[:alert_name]), alert_type_id: AlertType.find_id(params[:alert_type]),user_id: params[:user_id])
    if event.save
      event.alert_type.try(:name) == 'business' ? create_event_channels(event,'opinify') : create_event_channels(event,'inquirly')
      save_event_placeholders(event,params) if event.alert_type.try(:name) == 'consumer'
      { status: 200, event: final_response(event), success: 'Alert event created successfully'}
    else
      { status: 400, error: event.errors[:name]}
    end
  end

  def self.save_event_placeholders(event,params)
    email_config = {"recipients"=> [],"message"=>"","subject"=>"", "placeholders"=> placeholder_values(params)}
    sms_config   = {"recipients"=> [], "message"=>"", "placeholders"=> placeholder_values(params)}
    consumer_app_config = {"message"=>"", "placeholders"=> placeholder_values(params)}
    AlertConfig.create(alert_event_id: event.id, email: email_config, sms: sms_config, consumer_app: consumer_app_config)
  end

  def self.create_event_channels(event,type)
    channels = AlertChannel.all.where.not(name: type)
    channels.each do |channel|
      state = (channel.name == 'inquirly' || channel.name == 'opinify') ? true : false
      AlertEventChannel.create(is_active: event.alert_type.try(:name) == "business" ? state : true, alert_event_id: event.id,alert_channel_id: channel.id)
    end
  end

  def self.delete_event(params)
    event = where(id: params[:event_id], user_id: params[:user_id]).first
    event.destroy if event
    event
  end

  def self.change_status(params,user)
     where(id: params[:id],user_id: user.id).first.update_attributes(is_set_on: params[:is_set_on])
  end

  def self.create_consumer_event(params,user)
    new_event = new(name: params[:event_name].upcase, user_id: user.id)
    new_event.save ? {status: 200, response: 'Consumer Event set successfully'} : {status: 400, response: new_event.errors }
  end

  def self.update_event(params)
    response = {}
    event = where(id: params[:event_id]).first
    if event
      ok = event.update_attributes(name: params[:event_name])
      if ok
        update_placeholders(event,params)
        response = { status: 200, event: final_response(event), success: 'Alert event updated successfully'}
      else
        response = { status: 400, error: event.errors[:name]}
      end
    end
    response
  end

  def self.update_placeholders(event,params)
    config = event.alert_config
    if config
      config.email["placeholders"] = placeholder_values(params)
      config.sms["placeholders"] = placeholder_values(params)
      config.consumer_app["placeholders"] = placeholder_values(params)
      config.save
    end
  end

  def self.placeholder_values(params)
    values = []
    params[:placeholders].each do |p_holder|
      new_value = {}
      new_value["name"] = "{" + p_holder["name"] + "}"
      new_value["title"] = p_holder["title"]
      values << new_value
    end
    values
  end

  def self.final_response(event)
    { id: event.id,
      alert_id: Base64.encode64("u_#{event.user_id}_a_#{event.id}"),
      name: event.name,
      is_set: event.is_set_on,
      type: event.alert.try(:name),
      is_business_event: event.alert_type.try(:name) == "business",
      alert_config: event.alert_config,
      is_default: event.is_default,
      event_channels: event.alert_event_channels.order(id: :asc).collect{ |i| i.as_json(:except => [:alert_event_id, :alert_channel_id, :created_at, :updated_at], :methods => [:channel_name])}
    }
  end
end