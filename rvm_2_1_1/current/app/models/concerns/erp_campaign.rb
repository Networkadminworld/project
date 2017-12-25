module ErpCampaign
  extend ActiveSupport::Concern
  included do

    def self.email_campaign(params,user,question)
      question_image = question.attachment.present? ? question.attachment.image(:thumb) : ""
      email_array = email_collection(params,user,question)
      ShareDetail.update_share_count(user,email_array.count,'email_count')
      Delayed::Job.enqueue(MailerJob.new(email_array,params[:subject],params[:message],question_image,user,question.id, params[:is_html]), 2)
    end

    def self.sms_campaign(params,user)
      sms_file,numbers = sms_collection(params,user)
      ShareDetail.update_share_count(user,numbers.count,'sms_count') if numbers.count > 0
      Delayed::Job.enqueue(SmsIndia.new(sms_file, ERB::Util.url_encode(params[:message])), 1)
    end

    def self.call_campaign(params,user,question,content)
      make_call_file,numbers = call_collection(params,user)
      uniq_numbers = numbers.uniq
      ShareDetail.update_share_count(user,uniq_numbers.count,'call_count')
      Delayed::Job.enqueue(VoiceJob.new(uniq_numbers, question.id,content,"false"), 0)
    end


    private

    def self.email_collection(params,user,question)
      to_address = params[:is_select_all] == "true" ? filtered_contact_list(user,'email') : params[:to].split(",")
      remove_list = params[:unselected_customers].split(",")
      to_address = to_address.each.reject{|x| remove_list.each.include? x}
      email_array = []
      user.share_questions.create(:provider => "Email", :email_address => user.email)
      custom_url = question.custom_url("email",nil,nil)
      to_address.each { |email|
        email_share_collection = {"email" => email, "bitly_url" => custom_url}
        email_array << email_share_collection
      }
      email_array
    end

    def self.sms_collection(params,user)
      mobile_numbers = params[:is_select_all] == "true" ? filtered_contact_list(user,'sms') : params[:phone_number_sms].split(",")
      remove_list = params[:unselected_customers].split(",")
      mobile_numbers = mobile_numbers.each.reject{|x| remove_list.each.include? x}
      file = "/tmp/inter_sms_camp_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
      change_header_value(file,mobile_numbers.uniq)
    end

    def self.call_collection(params,user)
      mobile_numbers = params[:is_select_all] == "true" ? filtered_contact_list(user,'call') : params[:phone_number].split(",")
      remove_list = params[:unselected_customers].split(",")
      mobile_numbers = mobile_numbers.each.reject{|x| remove_list.each.include? x}
      file = "/tmp/inter_voice_camp_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
      change_header_value(file,mobile_numbers.uniq)
    end

    def self.filtered_contact_list(user,type)
      customer_list = []
      data = RestClient.post('http://preschoolapi.vanward.co/centrescontact?auth_token=c504a4200e0b232a8b1050d11f6e59310e45e641e413bd1772a0206cafd74975','')
      response = JSON.parse(data)
      response.each do |res|
        if type == 'email'
          customer_list << res["email"]
        else
          customer_list << res["mobile"]
        end
      end
      customer_list
    end
  end
end