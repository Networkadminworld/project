require 'erb'
require 'rest_client'
require 'csv'
module EventChannelService
  extend ActiveSupport::Concern
  included do

    def self.trigger_post_event(event,user,post_params,params,is_service_user=false)
      event_posts = []
      event_posts_recipients = []
      if event.name == 'NEW_SALES_ORDER'
        event_posts,event_posts_recipients = business_order_event(event,post_params,user)
      else
        event.alert_event_channels.each do |channel|
          if event.alert_type.try(:name) == 'business'
            if is_service_user
              event_posts, event_posts_recipients = service_user_alert(channel,post_params,user)
            else
              if channel.channel_name == 'email' && channel.is_active
                event_posts << {:post_id => send_email_alert(post_params,user), :channel => 'email', :type => 'business' }
                event_posts_recipients << {:recipients => post_params[:email_recipients], :channel => 'email', :type => 'business' }
              elsif channel.channel_name == 'sms' && channel.is_active
                event_posts << {:post_id => send_sms_alert(post_params,'business'), :channel => 'sms', :type => 'business' }
                event_posts_recipients << {:recipients => post_params[:sms_recipients], :channel => 'sms', :type => 'business'}
              elsif channel.channel_name == 'inquirly' && channel.is_active
                event_posts << {:post_id => send_business_app_alert(post_params,user.email), :channel => 'inquirly', :type => 'business' }
                event_posts_recipients << {:recipients => post_params[:app_recipients], :channel => 'inquirly', :type => 'business'}
              end
            end
          else
            if channel.channel_name == 'email' && channel.is_active
              event_posts << consumer_email_condition(event,post_params,user)
              event_posts_recipients << {:recipients => post_params[:email_recipients], :channel => 'email', :type => 'consumer' }
            elsif channel.channel_name == 'sms' && channel.is_active
              event_posts << {:post_id => send_sms_alert(post_params,'consumer'), :channel => 'sms', :type => 'consumer' }
              event_posts_recipients << {:recipients => post_params[:sms_recipients], :channel => 'sms', :type => 'consumer'}
            elsif channel.channel_name == 'opinify' && channel.is_active
            end
          end
        end
      end
      [event_posts,event_posts_recipients]
    end

    def self.consumer_email_condition(event,post_params,user)
      if event.alert_type.try(:name) == 'consumer' && event.is_default
        response = {:post_id => send_consumer_email(post_params), :channel => 'email', :type => 'consumer' }
      else
        if event.alert_config.try(:is_html)
          response = {:post_id => pipeline2_consumer_html_email(post_params,user), :channel => 'email', :type => 'consumer' }
        else
          response = {:post_id => send_email_alert(post_params,user), :channel => 'email', :type => 'consumer' }
        end
      end
      response
    end

    def self.service_user_alert(channel,post_params,user)
      event_posts = []
      event_posts_recipients= []
      case channel.channel_name
        when 'email'
          event_posts << {:post_id => send_email_alert(post_params,user), :channel => 'email', :type => 'business' }
          event_posts_recipients << {:recipients => post_params[:email_recipients], :channel => 'email', :type => 'business' }
        when 'sms'
          event_posts << {:post_id => send_sms_alert(post_params, 'business'), :channel => 'sms', :type => 'business' }
          event_posts_recipients << {:recipients => post_params[:sms_recipients], :channel => 'sms', :type => 'business'}
        when 'inquirly'
          event_posts << {:post_id => send_business_app_alert(post_params,post_params[:email_recipients]), :channel => 'inquirly', :type => 'business' }
          event_posts_recipients << {:recipients => post_params[:app_recipients], :channel => 'inquirly', :type => 'business'}
        else
      end
      [event_posts,event_posts_recipients]
    end

    def self.business_order_event(event,post_params,user)
      event_posts = []
      event_posts_recipients = []
      event.alert_event_channels.each do |channel|
        if event.alert_type.try(:name) == 'business'
          if channel.channel_name == 'email' && channel.is_active
            event_posts << {:post_id => send_consumer_email(post_params), :channel => 'email', :type => 'business' }
            event_posts_recipients << {:recipients => post_params[:email_recipients], :channel => 'email', :type => 'business' }
          elsif channel.channel_name == 'sms' && channel.is_active
            event_posts << {:post_id => send_sms_alert(post_params, 'business'), :channel => 'sms', :type => 'business' }
            event_posts_recipients << {:recipients => post_params[:sms_recipients], :channel => 'sms', :type => 'business'}
          elsif channel.channel_name == 'inquirly' && channel.is_active
            event_posts << {:post_id => send_business_app_alert(post_params,user.email), :channel => 'inquirly', :type => 'business' }
            event_posts_recipients << {:recipients => post_params[:app_recipients], :channel => 'inquirly', :type => 'business'}
          end
        end
      end
      [event_posts,event_posts_recipients]
    end

    def self.send_email_alert(post_params,user=nil)
      return if post_params[:email_recipients] == [""] || post_params[:email_recipients].first.strip == ""
      addresses = []
      merge_vars = []
      post_params[:email_recipients].each do |email|
        addresses << { email: email }
        merge_vars << { rcpt: email, vars: [{ name: 'merge', content: replace_message(post_params[:email_message]) }]}
      end
      mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
      template_name = "Inquirly-alert-template"
      template_content = [{ :name    => 'header',:content => ""}]
      message  = {
          :merge => true,
          :merge_vars => merge_vars,
          :subject => post_params[:subject],
          # HARDCODED EMAIL FOR COOLBERRYZ
          :from_name => user && user.try(:email) == "inquirly6+user1@gmail.com" ? "Coolberryz RR Nagar" : "Inquirly Admin",
          :from_email => ENV["ALERT_EMAIL"],
          :to => addresses,
          :important => true
      }
      post = mandrill.messages.send_template template_name, template_content, message
      MANDRILL_LOGGER.info("Alert Response for Businesses: #{post}")
      post.first["_id"] if post
    end

    def self.send_sms_alert(post_params,alert_type)
      return if post_params[:sms_recipients] == [""] || post_params[:sms_recipients].first.strip == ""
      indian_numbers,i18n_numbers = [],[]
      file = "/tmp/sms_alerts_list_#{Time.now.strftime('%H:%M:%S')}.csv"
      post_params[:sms_recipients].each do |number|
        number.start_with?("91") ? indian_numbers << number : i18n_numbers << number
      end
      CSV.open(file, "wb") do |csv|
        csv << ["PHONE","MESSAGE", "MASKS"]
        indian_numbers.each do |number|
          csv << [number,post_params[:sms_message],'Custom']
        end
      end
      user_id =  alert_type == 'business' ? ENV["GUPSHUP_USERID"] : ENV["TS_GUPSHUP_USERID"]
      password = alert_type == 'business' ? ENV["GUPSHUP_PASSWORD"] : ENV["TS_GUPSHUP_PASSWORD"]
      status = RestClient.post('http://enterprise.smsgupshup.com/GatewayAPI/rest', :xlsFile => File.new(file), :method => "xlsUpload", :userid => user_id, :password => password, :msg => ERB::Util.url_encode(post_params[:sms_message]), :msg_type => "TEXT", :version => "1.1", :auth_scheme => "PLAIN", :filetype => "csv")
      GUPSHUP_LOGGER.info("Gupshup Response: #{status}")
      send_118n_sms_alert(i18n_numbers,post_params)
      status.split("|").last.scan(/\d+/).first if status.split("|").first.strip == "success"
    end

    def self.send_118n_sms_alert(numbers,post_params)
      all_response = []
      numbers.each do |number|
        begin
          client = Twilio::REST::Client.new ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"]
          account = client.account
          response = account.sms.messages.create({:from => "#{ENV["SMS_NUM"]}", :to => "+#{number}", :body => "#{post_params[:sms_message]}"})
          all_response << response["sid"]
        rescue => e
          TWILIO_LOGGER.info("Error in Alert (sms): #{e}")
        end
      end
      all_response
    end

     def self.send_business_app_alert(post_params,emails)
      unless post_params[:app_recipients].blank?
        gcm = GCM.new(ENV['GCM_APP_KEY'])
        users = User.where(email: emails)
        users.each do |user|
          message =  {
              data: {
                  message: post_params[:biz_app_message],
                  userID: user.email,
                  notificationID: post_params[:post_id],
                  sentimentType: '',
                  imageURL: '',
                  appModule: post_params[:app_module],
                  postID: post_params[:post_id] ,
                  type: post_params[:post_type],
                  postState: post_params[:state]
              },
              priority: "high",
              time_to_live: 0
          }
          response = gcm.send(user.devices.map(&:device_id).reject(&:nil?).reject(&:blank?).uniq, message)
          GCM_LOGGER.info("GCM Push Response: #{response}")
        end
      end
      post_params[:app_recipients] || []
    end

    def self.send_consumer_email(post_params)
      return if post_params[:email_recipients] == [""] || post_params[:email_recipients].first.strip == ""
      addresses = []
      merge_vars = []
      post_params[:email_recipients].each do |email|
        addresses << { email: email }
        merge_vars << { rcpt: email, vars: [
              {name: 'MESSAGE',content: post_params[:email_message]},
              {name: 'NAME', content: post_params[:first_name] },
              {name: 'ITEM_CODE', content: post_params[:item_code] },
              {name: 'ITEM_SRC', content: post_params[:item_image_src] },
              {name: 'ITEM_NAME', content: post_params[:item_name] },
              {name: 'ITEM_PRICE', content: post_params[:item_price] },
              {name: 'CUSTOMER_NAME', content: post_params[:first_name] },
              {name: 'CUSTOMER_PHONE', content: post_params[:phone] },
              {name: 'CUSTOMER_DETAILS', content: post_params[:address] },
        ]}
      end
      mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
      template_name = "order-details"
      template_content = [{ :name    => 'header',:content => ""}]
      message  = {
          :merge => true,
          :merge_vars => merge_vars,
          :merge_language => "handlebars",
          :subject => post_params[:subject],
          :from_email => ENV["ALERT_EMAIL"],
          :to => addresses,
          :important => true
      }
      post = mandrill.messages.send_template template_name, template_content, message
      MANDRILL_LOGGER.info("Alert Response for #{post_params[:email_recipients]} Consumers: #{post}")
      post.first["_id"] if post
    end

    def self.pipeline2_consumer_html_email(post_params,user=nil)
      return if post_params[:email_recipients] == [""] || post_params[:email_recipients].first.strip == ""
      addresses = []
      post_params[:email_recipients].each do |email|
        addresses << { email: email }
      end
      mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
      message  = {
          :subject => post_params[:subject],
          :html => post_params[:email_message],
          :from_name => user && user.try(:email) == "inquirly6+user1@gmail.com" ? "Coolberryz RR Nagar" : "Inquirly Admin",
          :from_email => ENV["ALERT_EMAIL"],
          :to => addresses,
          :important => true
      }
      post = mandrill.messages.send message
      MANDRILL_LOGGER.info("Alert Response for #{post_params[:email_recipients]} Consumers: #{post}")
      post.first["_id"] if post
    end

    def self.send_activity_email(post_params)
      addresses = []
      merge_vars = []
      post_params[:email_recipients].each do |recipient|
        addresses << { email: recipient[:email] }
        merge_vars << { rcpt: recipient[:email],vars: [{:name => "NAME",:content => recipient[:name]},{:name => "DATE",:content => post_params[:day]},
                {:name => "activities",:content => post_params[:activities]}]
        }
      end
      mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
      template_name = "activity-reminder"
      template_content = [{ :name => 'header',:content => ""}]
      message  = {
          :subject => "Inquirly: Activity Reminder for #{post_params[:day]}",
          :from_email => ENV["ALERT_EMAIL"],
          :to=> addresses,
          :auto_text => true,
          :inline_css => true,
          :merge => true,
          :merge_language => "handlebars",
          :global_merge_vars => [],
          :merge_vars => merge_vars
      }
      post = mandrill.messages.send_template template_name, template_content, message
      MANDRILL_LOGGER.info("Alert Response for #{post_params[:email_recipients]} Consumers: #{post}")
      post.first["_id"] if post
    end

    def self.replace_message(message)
      br = '<br />'
      message = message.gsub("\r\n",br).gsub("\n\r",br).gsub("\r",br).gsub("\n",br)
      message
    end

  end
end
