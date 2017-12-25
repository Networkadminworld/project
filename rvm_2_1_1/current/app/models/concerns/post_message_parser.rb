module PostMessageParser
  extend ActiveSupport::Concern
  included do
    def self.email_message_parser(email_message,params,is_consumer)
      params[:event_params][:place_holders].each do |key,value|
        email_message = email_message.gsub(key, value) if email_message && email_message.include?(key)
      end
      is_consumer ? email_message : update_call_to_action(email_message,params)
    end

    def self.sms_message_parser(sms_message,params,is_consumer)
      params[:event_params][:place_holders].each do |key,value|
        sms_message = sms_message.gsub(key, value) if sms_message && sms_message.include?(key)
      end
      is_consumer ? sms_message : update_sms_call_to_action(sms_message,params)
    end

    def self.app_message_parser(biz_app_message,params,is_consumer)
      params[:event_params][:place_holders].each do |key,value|
        biz_app_message = biz_app_message.gsub(key, value) if biz_app_message &&biz_app_message.include?(key)
      end
      is_consumer ? biz_app_message : update_app_post_cta(biz_app_message)
    end

    def self.update_call_to_action(email_message,params)
      email_message ? email_message + " <a href=#{params[:event_params][:callback_url]}>VIEW POST</a>" : "<a href=#{params[:event_params][:callback_url]}>VIEW POST</a>"
    end

    def self.update_app_post_cta(biz_app_message)
      biz_app_message ? biz_app_message + "VIEW POST" : "You have received an alert. VIEW POST"
    end

    def self.update_sms_call_to_action(sms_message,params)
      client = BitLyService.new
      short_link = client.shorten({url: params[:event_params][:callback_url], secret: ENV['SHORTEN_SECRET']})["short_url"]
      sms_message ? sms_message + short_link : short_link
    end

    def self.parse_subject(subject,params)
      params[:event_params][:place_holders].each do |key,value|
        subject = subject.gsub(key, value) if subject && subject.include?(key)
      end
      subject
    end
  end
end