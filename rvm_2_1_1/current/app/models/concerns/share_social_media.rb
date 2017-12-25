module ShareSocialMedia
	extend ActiveSupport::Concern
  included do

    def self.fb_share
      message = replace_bit_ly_url('facebook')
      @fb_accounts.each do |credential|
        page = FbGraph2::User.me(credential.social_token)
        tries = 2
        begin
          if @campaign_data["media_shorten_url"].present?
            post = page.photo!(:caption => campaign_message(message,'facebook').strip,
                               :url => @campaign_data["media_shorten_url"])
          else
            post = page.feed!(:message => campaign_message(message,'facebook'),
                              :link => fb_short_link,
                              :picture => @campaign_data["og_meta_data"].blank? ? '' : @campaign_data["og_meta_data"]["image"],
                              :name => @campaign_data["footer"]["fb_feed_name"],
                              :caption => @campaign_data["footer"]["fb_feed_caption"],
                              :description => @campaign_data["footer"]["fb_description"])
          end
          CampaignChannel.save_post_info(post.identifier, credential,@campaign,ShareMedium._id("Social"))
        rescue => e
          tries -= 1
          if tries > 0
            retry
          else
            post_url = "#{ENV['CUSTOM_URL']}/#/campaigns/index?src=campaign&cid=#{@campaign.campaign_uuid}"
            remove_unshared_channels(credential.social_id,'facebook')
            AlertLog.send_event(alert_event_params('SHARE_API_EXCEPTION',post_url,"CAMPAIGNS","FACEBOOK","FACEBOOK ERROR: #{e}",@campaign,@campaign.user_id))
            Delayed::Worker.logger.debug("FACEBOOK ERROR: #{e}")
          end
        end
      end
    end

    def self.campaign_message(message,channel)
      detail = @campaign.reload.campaign_detail
      if channel == 'facebook'
        short_link = detail.campaign_short_urls["fb_shorten_url"]
      elsif channel == 'twitter'
        short_link = detail.campaign_short_urls["tw_shorten_url"]
      else
        short_link = detail.campaign_short_urls["ln_shorten_url"]
      end
      if @campaign_data["media_shorten_url"].present?
        message.gsub(short_link,'').gsub(@campaign_data["media_shorten_url"],'').gsub(@campaign_data["shorten_url"], '')
      else
        @campaign_data["shorten_url"].present? ? message.gsub(short_link,'').gsub(@campaign_data["shorten_url"], '') : message
      end
    end

    def self.fb_short_link
      if @campaign_data["media_shorten_url"].present?
        @campaign_data["media_shorten_url"]
      else
        fb_shorten_url = @campaign.reload.campaign_detail.campaign_short_urls["fb_shorten_url"]
        fb_shorten_url.present? ? fb_shorten_url : @campaign_data["shorten_url"]
      end
    end

    def self.tw_share
      message = replace_bit_ly_url('twitter')
      @tw_accounts.each do |credential|
        Twitter.configure do |config|
          config.consumer_key = OMNIAUTH_KEYS["tw_client_id"]
          config.consumer_secret = OMNIAUTH_KEYS["tw_client_secret"]
          config.oauth_token = credential.social_token
          config.oauth_token_secret = credential.social_id
        end
        begin
          if @campaign_data["campaign_media_url"].present?
            self.twitter_media_share(message,credential)
          else
            post = Twitter.update(message || @campaign_data["shorten_url"])
            CampaignChannel.save_post_info(post.attrs[:id], credential,@campaign,ShareMedium._id("Social")) if post && post.attrs
          end
        rescue => e
          post_url = "#{ENV['CUSTOM_URL']}/#/campaigns/index?src=campaign&cid=#{@campaign.campaign_uuid}"
          remove_unshared_channels(credential.social_id,'twitter')
          AlertLog.send_event(alert_event_params('SHARE_API_EXCEPTION',post_url,"CAMPAIGNS","TWITTER","TWITTER ERROR: #{e}",@campaign,@campaign.user_id))
          Delayed::Worker.logger.debug("TWITTER ERROR: #{e}")
        end
      end
    end

    def self.ln_share
      message = replace_bit_ly_url('linkedin')
      @ln_message = campaign_message(message,'linkedin')
      @ln_short_url = @campaign.reload.campaign_detail.campaign_short_urls["ln_shorten_url"]
      @ln_accounts.each do |credential|
        begin
          @api = LinkedIn::API.new(credential.social_token)
          @company_page = LinkedinCompanyPage.where(user_id: @user_id, user_social_channel_id: credential.id).first
          @company_page ? share_linkedin_company_page :  share_linkedin_account
          CampaignChannel.save_post_info("UPDATE-#{SecureRandom.hex(5)}", credential,@campaign,ShareMedium._id("Social"))
        rescue => e
          post_url = "#{ENV['CUSTOM_URL']}/#/campaigns/index?src=campaign&cid=#{@campaign.campaign_uuid}"
          remove_unshared_channels(credential.social_id,'linkedin')
          AlertLog.send_event(alert_event_params('SHARE_API_EXCEPTION',post_url,"CAMPAIGNS","LINKEDIN","LINKEDIN ERROR: #{e}",@campaign,@campaign.user_id))
          Delayed::Worker.logger.debug("LINKEDIN ERROR: #{e}")
        end
      end
    end

    def self.share_linkedin_company_page
      if @campaign_data["campaign_media_url"].present?
        response = @api.add_company_share(@company_page.company_id, :comment => @ln_message,
                              :content => {"title" =>  @campaign_data["footer"]["ln_title"],
                                           "submitted-url" => @campaign_data["media_shorten_url"],
                                           "submitted-image-url" => @campaign_data["campaign_media_url"]})
      else
        data = @campaign_data["og_meta_data"]
        if @ln_short_url.present?
          response = @api.add_company_share(@company_page.company_id, :comment => @ln_message,
                              :content => {"title"  => data["title"] || '',
                                           "description" => data["description"] || '',
                                           "submitted-url" =>  @ln_short_url,
                                           "submitted-image-url" => data["image"]})
        else
          response = @api.add_company_share(@company_page.company_id, :comment => @ln_message)
        end
      end
      Delayed::Worker.logger.debug("LINKEDIN COMPANY PAGE SHARE: #{response.inspect}")
    end


    def self.share_linkedin_account
      if @campaign_data["campaign_media_url"].present?
        response = @api.add_share(:comment => @ln_message,
                       :content => {"title" =>  @campaign_data["footer"]["ln_title"],
                                   "submitted-url" => @campaign_data["media_shorten_url"],
                                   "submitted-image-url" => @campaign_data["campaign_media_url"]})
      else
        data = @campaign_data["og_meta_data"]
        if @ln_short_url.present?
          response = @api.add_share(:comment => @ln_message,
                         :content => {"title" =>  data["title"],
                                      "description" => data["description"],
                                      "submitted-url" => @ln_short_url,
                                      "submitted-image-url" => data["image"]})
        else
          response = @api.add_share(:comment => @ln_message)
        end
      end
      Delayed::Worker.logger.debug("LINKEDIN ACCOUNT SHARE: #{response.inspect}")
    end

    def self.social_process(params,user,campaign)
      if campaign.fb_channels.count > 0 || campaign.tw_channels.count > 0 || campaign.ln_channels.count > 0
        Delayed::Job.enqueue SocialShareJob.new(campaign,user), priority: 0, run_at: params[:schedule_on], campaign_id: campaign.id, user_id: user.id, share_now: params[:share_now]
      end
    end

    def self.share_social_content(campaign,user)
      @fb_accounts = []
      @tw_accounts = []
      @ln_accounts = []
      @campaign = campaign
      @campaign_data = JSON.parse(@campaign.campaign_detail.campaign_data)
      @user_id  = user.id
      all_channels = @campaign.fb_channels.map(&:id) + @campaign.tw_channels.map(&:id) + @campaign.ln_channels.map(&:id)
      channels = UserSocialChannel.where(id: all_channels, active: true, user_id: user.id)
      channels.each do |u_channel|
        @fb_accounts << u_channel if u_channel.channel == "facebook"
        @tw_accounts << u_channel if u_channel.channel == "twitter"
        @ln_accounts << u_channel if u_channel.channel == "linkedin"
      end
      if @campaign.long_url
        if @fb_accounts.length > 0
          create_channel_short_url(@campaign,'facebook')
          fb_share
        end
        if @tw_accounts.length > 0
          create_channel_short_url(@campaign,'twitter')
          tw_share
        end
        if @ln_accounts.length > 0
          create_channel_short_url(@campaign,'linkedin')
          ln_share
        end
      else
        fb_share if @fb_accounts.length > 0
        tw_share if @tw_accounts.length > 0
        ln_share if @ln_accounts.length > 0
      end
    end

    def self.create_channel_short_url(campaign,channel)
      BitLyService.new.create_shorten_url(channel,campaign)
      @campaign = campaign.reload
      @campaign_data = JSON.parse(@campaign.campaign_detail.campaign_data)
    end

    def self.twitter_media_share(message,credential)
      uri = URI.parse(@campaign_data["campaign_media_url"])
      media = uri.open
      if File.basename(uri.path).class != String
        media.instance_eval("def original_filename; '#{File.basename(uri.path)}'; end")
        post = Twitter.update_with_media(campaign_message(message,'twitter'), media)
      else
        url = parse_image_url @campaign_data["campaign_media_url"]
        post = Twitter.update_with_media(campaign_message(message,'twitter'), File.open(url))
      end
      CampaignChannel.save_post_info(post.attrs[:id], credential,@campaign,ShareMedium._id("Social")) if post && post.attrs
    end

    def self.parse_image_url(url)
      extname = File.extname(url)
      basename = File.basename(url, extname)
      file = Tempfile.new([basename, extname])
      uri = file.binmode
      open(URI.parse(url)) do |data|
        file.write data.read
      end
      file.rewind
      uri
    end

    def self.replace_bit_ly_url(channel)
      if channel == "facebook"
        fb_short_url = @campaign.reload.campaign_detail.campaign_short_urls["fb_shorten_url"]
        fb_short_url.present? ? @campaign_data["share_content"].gsub(@campaign_data["shorten_url"],fb_short_url) : @campaign_data["share_content"]
      elsif channel == "twitter"
        tw_short_url = @campaign.reload.campaign_detail.campaign_short_urls["tw_shorten_url"]
        tw_short_url.present? ? @campaign_data["share_content"].gsub(@campaign_data["shorten_url"],tw_short_url) : @campaign_data["share_content"]
      else
        ln_short_url = @campaign.reload.campaign_detail.campaign_short_urls["ln_shorten_url"]
        ln_short_url.present? ? @campaign_data["share_content"].gsub(@campaign_data["shorten_url"],ln_short_url) : @campaign_data["share_content"]
      end
    end

    def self.alert_event_params(event_name,callback_url,module_name,campaign_channel,error_message,campaign,user_id)
      {
        :event_name => event_name,
        :user_id => user_id,
        :event_params => {
          :campaign_id => campaign.id,
          :callback_url => callback_url,
          :place_holders => {
            "{campaign_name}" => campaign.label,
            "{campaign_channel}" => campaign_channel,
            "{error_msg}" => error_message
          },
          :callback_app => {
            :response_id => campaign.id,
            :module => module_name
          },
          :post_state => 'HISTORY'
        }
      }
    end

    def self.remove_unshared_channels(social_id,channel)
      if channel == 'facebook'
        user_social_channel_id = @campaign.fb_channels.where(social_id: social_id).first.try(:id)
      elsif channel == 'twitter'
        user_social_channel_id = @campaign.tw_channels.where(social_id: social_id).first.try(:id)
      else
        user_social_channel_id = @campaign.ln_channels.where(social_id: social_id).first.try(:id)
      end
      user_channel_id = UserChannel.where(channel_type: 'UserSocialChannel', channel_id: user_social_channel_id).first.try(:id)
      campaign_channel = CampaignChannel.where(user_channel_id: user_channel_id, campaign_id: @campaign.id).first
      campaign_channel.destroy if campaign_channel
    end

  end
end