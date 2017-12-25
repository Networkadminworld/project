class AlertScript
	
	def initialize
		@users = User.all.where.not(email: [ENV["ADMIN_EMAIL"]])
		@campaign_alert_id = Alert.where(name: "campaigns").first.id
		@pipeline_alert_id = Alert.where(name: "pipeline").first.id
    @system_alert_id = Alert.where(name: "system").first.id
		@biz_alert_type_id = AlertType.where(name: "business").first.id
		@con_alert_type_id = AlertType.where(name: "consumer").first.id
		@biz_alert_channels = AlertChannel.all.where.not(name: "opinify")
		@con_alert_channels = AlertChannel.all.where.not(name: "inquirly")
	end

	def campaign_alert_events
		campaign_events = ["SCHEDULED_CAMPAIGN", "SCHEDULED_CAMPAIGN_SHARED", "CAMPAIGN_WAITING_FOR_APPROVAL","CAMPAIGN_APPROVED", "CAMPAIGN_REJECTED"]
		@users.each do |user|
			campaign_events.each do |event|
				if AlertEvent.where(name: event, user_id: user.id).blank?
          email_config, sms_config, biz_app_config = campaign_alert_config(event,user)
					event = AlertEvent.create(name: event, is_set_on: true, is_default: true,user_id: user.id, company_id: user.company.try(:id), alert_id: @campaign_alert_id,alert_type_id: @biz_alert_type_id)
          AlertConfig.create(alert_event_id: event.id, email: email_config, sms: sms_config, business_app: biz_app_config)
					@biz_alert_channels.each do |channel|
            state = channel.name == 'inquirly' ? true : false
						AlertEventChannel.create(is_active: ["CAMPAIGN_APPROVED", "CAMPAIGN_REJECTED"].include?(event.name) ? true : state, alert_event_id: event.id, alert_channel_id: channel.id)
					end
				end
			end
		end
  end

  def campaign_alert_config(event,user)
    case event
      when 'SCHEDULED_CAMPAIGN'
      email_config = {"recipients"=>[{"text"=> user.email}],
                      "message"=>"Your campaign {campaign_name} scheduled for {scheduled_date} will be shared at {alert_time}.",
                      "subject"=>"Inquirly Alert: Scheduled campaign will be share today.",
                      "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{scheduled_date}", "title"=>"The date of the scheduled campaign"}, {"name"=>"{alert_time}", "title"=>"The time before the scheduled campaign posted"}]}
      sms_config   =   {"recipients"=>[], "message"=>"Your campaign {campaign_name} scheduled for {scheduled_date} will be shared at {alert_time}.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{scheduled_date}", "title"=>"The date of the scheduled campaign"}, {"name"=>"{alert_time}", "title"=>"The time before the scheduled campaign posted"}]}

      biz_app_config = {"message"=>"Your campaign {campaign_name} scheduled for {scheduled_date} will be shared at {alert_time}.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{scheduled_date}", "title"=>"The date of the scheduled campaign"}, {"name"=>"{alert_time}", "title"=>"The time before the scheduled campaign posted"}]}
      when 'SCHEDULED_CAMPAIGN_SHARED'
      email_config = {"recipients"=>[{"text"=> user.email}],
                      "message"=>"Your campaign {campaign_name} scheduled for {scheduled_date} has been shared.",
                      "subject"=>"Inquirly Alert: Scheduled powershare campaign has been shared",
                      "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{scheduled_date}", "title"=>"The date of the scheduled campaign"}]}
      sms_config   =   {"recipients"=>[], "message"=>"Your campaign {campaign_name} scheduled for {scheduled_date} has been shared",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{scheduled_date}", "title"=>"The date of the scheduled campaign"}]}

      biz_app_config = {"message"=>"Your campaign {campaign_name} scheduled for {scheduled_date} has been shared.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{scheduled_date}", "title"=>"The date of the scheduled campaign"}]}
      when 'CAMPAIGN_WAITING_FOR_APPROVAL'
      email_config = {"recipients"=>[{"text"=> user.email}],
                      "message"=>"Your campaign {campaign_name} created by {service_user_name} has waiting for approval.",
                      "subject"=>"Inquirly Alert: New campaign {campaign_name} waiting for approval",
                      "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{service_user_name", "title"=>"The name of the user who created the campaign"}]}
      sms_config   =   {"recipients"=>[], "message"=>"Your campaign {campaign_name} created by {service_user_name} has waiting for approval.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{service_user_name}", "title"=>"The name of the user who created the campaign"}]}

      biz_app_config = {"message"=>"Your campaign {campaign_name} created by {service_user_name} has waiting for approval.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"},{"name"=>"{service_user_name}", "title"=>"The name of the user who created the campaign"}]}
      when 'CAMPAIGN_APPROVED'
        email_config = {"recipients"=>[],"message"=>"Your campaign {campaign_name} has been {status}.","subject"=>"Inquirly Alert:  Your campaign has been {status}","placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"}, {"name"=>"{status}", "title"=>"The status of the campaign(Approved/Rejected)"}]}
        sms_config   =   {"recipients"=>[], "message"=>"Your campaign {campaign_name} has been {status}.","placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"}, {"name"=>"{status}", "title"=>"The status of the campaign(Approved/Rejected)"}]}
        biz_app_config = {"message"=>"Your campaign {campaign_name} has been {status}.","placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"}, {"name"=>"{status}", "title"=>"The status of the campaign(Approved/Rejected)"}]}
      else
        email_config = {"recipients"=>[],"message"=>"Your campaign {campaign_name} has been {status}.","subject"=>"Inquirly Alert:  Your campaign has been {status}","placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"}, {"name"=>"{status}", "title"=>"The status of the campaign(Approved/Rejected)"}]}
        sms_config   =   {"recipients"=>[], "message"=>"Your campaign {campaign_name} has been {status}.","placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"}, {"name"=>"{status}", "title"=>"The status of the campaign(Approved/Rejected)"}]}
        biz_app_config = {"message"=>"Your campaign {campaign_name} has been {status}.","placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign"}, {"name"=>"{status}", "title"=>"The status of the campaign(Approved/Rejected)"}]}
    end
    [email_config,sms_config,biz_app_config]
  end

	def pipeline_alert_events
		pipeline_biz_events = ["NEW_SALES_ORDER", "NEW_MARKETING_LEAD", "REMINDER_APPOINTMENT", "MARKETING_LEAD_STATE_CHANGE", "MARKETING_LEAD_ASSIGNED"]
		pipeline_cus_events = ["SALES_ORDER_ACCEPT", "SALES_ORDER_ASSIGNED", "SALES_ORDER_DELIVERED", "SALES_ORDER_REJECT"]
		@users.each do |user|
			pipeline_biz_events.each do |event|
				if AlertEvent.where(name: event, user_id: user.id).blank?
          email_config, sms_config, biz_app_config = pipeline_alert_config(event,user)
          event = AlertEvent.create(name: event, is_set_on: true, is_default: true, user_id: user.id, company_id: user.company.try(:id), alert_id: @pipeline_alert_id,alert_type_id: @biz_alert_type_id)
          AlertConfig.create(alert_event_id: event.id, email: email_config, sms: sms_config, business_app: biz_app_config)
          @biz_alert_channels.each do |channel|
            state = channel.name == 'inquirly' ? true : false
						AlertEventChannel.create(is_active: state, alert_event_id: event.id, alert_channel_id: channel.id)
					end
				end
			end
			pipeline_cus_events.each do |event|
				if AlertEvent.where(name: event, user_id: user.id).blank?
          email_config, sms_config, consumer_app_config = pipeline_consumer_config(event)
          event = AlertEvent.create(name: event, is_set_on: true, is_default: true, user_id: user.id, company_id: user.company.try(:id), alert_id: @pipeline_alert_id,alert_type_id: @con_alert_type_id)
          AlertConfig.create(alert_event_id: event.id, email: email_config, sms: sms_config, consumer_app: consumer_app_config)
					@con_alert_channels.each do |channel|
            state = channel.name == 'opinify' ? true : false
						AlertEventChannel.create(is_active: true, alert_event_id: event.id, alert_channel_id: channel.id)
					end
				end
			end
		end
  end

  def pipeline_alert_config(event,user)
    case event
     when 'NEW_SALES_ORDER'
        email_config = {"recipients"=>[{"text"=> user.email}],
                        "message"=>"You have received a new order for {product_id}.",
                        "subject"=>"Inquirly Alert: You have received a new order.",
                        "placeholders"=>[{"name"=>"{product_id}", "title"=>"The product code of the order item."}]}
        sms_config   =   {"recipients"=>[], "message"=>"You have received a new order for {product_id}.",
                          "placeholders"=>[{"name"=>"{product_id}", "title"=>"The product code of the order item."}]}

        biz_app_config = {"message"=>"You have received a new order for {product_id}.",
                        "placeholders"=>[{"name"=>"{product_id}", "title"=>"The product code of the order item."}]}
     when 'NEW_MARKETING_LEAD'
        email_config = {"recipients"=>[{"text"=> user.email}],
                        "message"=>"You have a new lead for {campaign_name}.",
                        "subject"=>"Inquirly Alert: You have a new lead.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign."}]}
        sms_config   =   {"recipients"=>[], "message"=>"You have a new lead for {campaign_name}.",
                          "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign."}]}

        biz_app_config = {"message"=>"You have a new lead for {campaign_name}.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign."}]}
      when 'REMINDER_APPOINTMENT'
        email_config = {"recipients"=>[{"text"=> user.email}],
                        "message"=>"Your appointment with {customer_name} is due on {due_date}.",
                        "subject"=>"Inquirly Alert: Appointment Reminder",
                        "placeholders"=>[{"name"=>"{customer_name}", "title"=>"The name of the customer"},{"name"=>"{due_date}", "title"=>"The due time of the appointment"}]}
        sms_config   =   {"recipients"=>[], "message"=>"Your appointment with {customer_name} is due on {due_date}.",
                          "placeholders"=>[{"name"=>"{customer_name}", "title"=>"The name of the customer"},{"name"=>"{due_date}", "title"=>"The due time of the appointment"}]}

        biz_app_config = {"message"=>"Your appointment with {customer_name} is due on {due_date}.",
                        "placeholders"=>[{"name"=>"{customer_name}", "title"=>"The name of the customer"},{"name"=>"{due_date}", "title"=>"The due time of the appointment"}]}
      when 'MARKETING_LEAD_ASSIGNED'
        email_config = {"recipients"=>[{"text"=> user.email}],
                        "message"=>"A new lead {lead_name} has been assigned to you.",
                        "subject"=>"Inquirly Alert: New lead assigned",
                        "placeholders"=>[{"name"=>"{lead_name", "title"=>"The name of the lead"}]}
        sms_config   =   {"recipients"=>[], "message"=>"A new lead {lead_name} has been assigned to you.",
                          "placeholders"=>[{"name"=>"{lead_name", "title"=>"The name of the lead"}]}

        biz_app_config = {"message"=>"A new lead {lead_name} has been assigned to you.",
                        "placeholders"=>[{"name"=>"{lead_name", "title"=>"The name of the lead"}]}
      when 'MARKETING_LEAD_STATE_CHANGE'
        email_config = {"recipients"=>[{"text"=> user.email}],
                        "message"=>"{user_name_of_marketing_exec} has marked {customer_name} lead as {status}",
                        "subject"=>"Inquirly Alert: New lead has marked as WON/LOST",
                        "placeholders"=>[{"name"=>"{user_name_of_marketing_exec}", "title"=>"Marketing executive name"},
                                         {"name"=>"{customer_name}", "title"=>"The customer name"},
                                         {"name"=>"{status}", "title"=>"Status of the lead.(won/lost) "}]}
        sms_config   =   {"recipients"=>[], "message"=>"{user_name_of_marketing_exec} has marked {customer_name} lead as {status}",
                          "placeholders"=>[{"name"=>"{user_name_of_marketing_exec}", "title"=>"Marketing executive name"},
                                           {"name"=>"{customer_name}", "title"=>"The customer name"},
                                           {"name"=>"{status}", "title"=>"Status of the lead.(won/lost) "}]}
        biz_app_config = {"message"=>"{user_name_of_marketing_exec} has marked {customer_name} lead as {status}",
                          "placeholders"=>[{"name"=>"{user_name_of_marketing_exec}", "title"=>"Marketing executive name"},
                                           {"name"=>"{customer_name}", "title"=>"The customer name"},
                                           {"name"=>"{status}", "title"=>"Status of the lead.(won/lost) "}]}
      else
        email_config,sms_config,biz_app_config = {}, {}, {}
    end
    [email_config,sms_config,biz_app_config]
  end

  def pipeline_consumer_config(event)
    case event
      when 'SALES_ORDER_ACCEPT'
        email_config = {"recipients"=>[],
                        "message"=>"Your order for {item_code} has been accepted and is under process.",
                        "subject"=>"Inquirly Alert: Your order has been accepted.",
                        "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}
        sms_config   =   {"recipients"=>[], "message"=>"Your order for {item_code} has been accepted and is under process.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}

        consumer_app_config = {"message"=>"Your order for {item_code} has been accepted and is under process.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}
      when 'SALES_ORDER_REJECT'
        email_config = {"recipients"=>[],
                        "message"=>"Your order for {item_code} has been rejected and is under process.",
                        "subject"=>"Inquirly Alert: Your order has been rejected",
                        "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}
        sms_config   =   {"recipients"=>[], "message"=>"Your order for {item_code} has been rejected and is under process.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}

        consumer_app_config = {"message"=>"Your order for {item_code} has been rejected and is under process.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}
      when 'SALES_ORDER_ASSIGNED'
        email_config = {"recipients"=>[],
                        "message"=>"Your order for {item_code} has been assigned to {delivery_name} for delivery.",
                        "subject"=>"Your order has been assigned to delivery",
                        "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."},{"name"=>"{delivery_name}", "title"=>"The name of the delivery boy."}]}
        sms_config   =   {"recipients"=>[], "message"=>"Your order for {item_code} has been assigned to {delivery_name} for delivery.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."},{"name"=>"{delivery_name}", "title"=>"The name of the delivery boy."}]}

        consumer_app_config = {"message"=>"Your order for {item_code} has been assigned to {delivery_name} for delivery.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."},{"name"=>"{delivery_name}", "title"=>"The name of the delivery boy."}]}
      else
        email_config = {"recipients"=>[],
                        "message"=>"Your order for {item_code} has been delivered successfully.",
                        "subject"=>"Your order has been delivered successfully.",
                        "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}
        sms_config   =   {"recipients"=>[], "message"=>"A new lead {lead_name} has been assigned to you.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}

        consumer_app_config= {"message"=>"Your order for {item_code} has been delivered successfully.",
                          "placeholders"=>[{"name"=>"{item_code}", "title"=>"The item code of the ordered item."}]}
    end
    [email_config,sms_config,consumer_app_config]
  end

  def system_alert_events
    system_events = ["SHARE_API_EXCEPTION","LINKEDIN_ACCOUNT_EXPIRY"]
    @users.each do |user|
      system_events.each do |event|
        if AlertEvent.where(name: event, user_id: user.id).blank?
          email_config, sms_config, biz_app_config = system_alert_config(event,user)
          event = AlertEvent.create(name: event, is_set_on: true, is_default: true,user_id: user.id, company_id: user.company.try(:id), alert_id: @system_alert_id,alert_type_id: @biz_alert_type_id)
          AlertConfig.create(alert_event_id: event.id, email: email_config, sms: sms_config, business_app: biz_app_config)
          @biz_alert_channels.each do |channel|
            state = channel.name == 'inquirly' ? true : false
            AlertEventChannel.create(is_active: state, alert_event_id: event.id, alert_channel_id: channel.id)
          end
        end
      end
    end
  end

  def system_alert_config(event,user)
    case event
      when 'SHARE_API_EXCEPTION'
        email_config = {"recipients"=>[{"text"=> user.email}],
                        "message"=>"Your campaign {campaign_name} was not shared on {campaign_channel} due to {error_msg}.",
                        "subject"=>"Inquirly Alert: Your Campaign post was not successful.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign."},{"name"=>"{campaign_channel}", "title"=>"The campaign shared channel."},
                                         {"name"=>"{error_msg}", "title"=>"backend error message detail."}]}
        sms_config   = {"recipients"=>[], "message"=>"Your campaign {campaign_name} was not shared on {campaign_channel} due to {error_msg}.",
                        "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign."},{"name"=>"{campaign_channel}", "title"=>"The campaign shared channel."},
                                         {"name"=>"{error_msg}", "title"=>"backend error message detail."}]}
        biz_app_config = {"message"=>"Your campaign {campaign_name} was not shared on {campaign_channel} due to {error_msg}.",
                          "placeholders"=>[{"name"=>"{campaign_name}", "title"=>"The name of the campaign."},{"name"=>"{campaign_channel}", "title"=>"The campaign shared channel."},
                                           {"name"=>"{error_msg}", "title"=>"backend error message detail."}]}
      else
        email_config,sms_config,biz_app_config = {}, {},{}
    end
    [email_config,sms_config,biz_app_config]
  end

	def run!
		campaign_alert_events
		pipeline_alert_events
    system_alert_events
	end
	
	def create_alert_config(user)
		@users = [user]
		campaign_alert_events
		pipeline_alert_events
    system_alert_events
	end
end

		


