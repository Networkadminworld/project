class EmailShare < MassMandrill::MandrillMailer
  include CustomersHelper

    def email_share(email_array,user,campaign,email_channel= [])
        addresses = []
        sub_id = (user.parent_id == 0 || user.parent_id == nil) ? "cust-#{user.id}" : "cust-#{user.parent_id}"
        fetch_campaign_detail(campaign)
        email_array.each { |customer| addresses << { email: customer } }
        post_id = "#{Time.now.strftime('%H:%M:%S')}?#{campaign.id}"
        begin
          mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
          message = {
              merge: false,
              from_email: @data["email_sender"].present? ? @data["email_sender"] : user.from_email,
              headers: { "Reply-To" => user.reply_email },
              from_name: user.from_name,
              subject: email_subject(user),
              html: @data["email_content"].present? ? @data["email_content"] : email_campaign_template(user,@data,campaign.campaign_type.try(:name)),
              to: addresses,
              subaccount: sub_id,
              async: true,
              metadata: { post_id: post_id ,campaign_name: campaign.label,user_id: user.id }
          }
          result =  mandrill.messages.send message
          save_mobile_post(post_id,campaign,email_channel) if result
        rescue Mandrill::Error => e
          MANDRILL_LOGGER.info("A mandrill error occurred(email): #{e.class} - #{e.message}")
        end
    end

    def email_subject(user)
      @data["email_subject"] ? @data["email_subject"] : (user.company ? "#{user.company.try(:name)} | Power Share" : "Power Share")
    end

    def fetch_campaign_detail(campaign)
      @data = JSON.parse(campaign.campaign_detail.campaign_data)
      email_short_link = campaign.campaign_detail.campaign_short_urls["email_shorten_url"]
      @data["email_shorten_url"] = email_short_link.present? ? email_short_link : @data['shorten_url']
      @data["share_content"].gsub!(@data['shorten_url'],'') if @data['shorten_url'] && !campaign.is_power_share
    end

    def save_mobile_post(post_id,campaign,email_channel)
      CampaignChannel.mobile_post_info(post_id, email_channel,campaign,ShareMedium._id("Mobile"))
    end
end
