class Campaign < ActiveRecord::Base
  include ShareSocialMedia
  include ShareOnMobile
  include CampaignInfo
  include CampaignCronTask
  include InLocationShare
  include CampaignAlertEvent
  include TestCampaignShare
  extend FriendlyId
  belongs_to :campaign_type
  belongs_to :user
  has_one :campaign_detail, dependent: :destroy
  has_many :campaign_channels, dependent: :destroy
  has_one :attachment, :as => :attachable, dependent: :destroy
  has_many :campaign_customers, dependent: :destroy
  has_many :campaign_activity_stats, dependent: :destroy
  belongs_to :share_medium, foreign_key: :share_medium_id
  has_one :inq_campaign, foreign_key: :inq_campaign_id
  friendly_id :slug, use: :slugged

  before_create :generate_unique_slug_key
  after_create  :update_share_detail_count, if: Proc.new { self.two_way_campaign }
  after_destroy :decrease_campaign_share_count, if: Proc.new { self.two_way_campaign }

  def self.create_power_share(user,params)
    params[:share_now] = (params[:share_now] == "false" || !params[:share_now]) ? false : true
    params[:schedule_on] = !params[:share_now] ? params[:schedule_on] : Time.zone.now
    campaign = create(label: params[:campaign_name],
                      user_id: params[:publisher_id] ? params[:publisher_id] : user.id,
                      campaign_type_id: CampaignType.get_id(params[:campaign_type]),
                      is_power_share: params[:is_power_share],
                      schedule_on: params[:schedule_on],
                      two_way_campaign: params[:mode] == 'TWO_WAY' ? true : false,
                      status: params[:campaign_state],
                      time_zone: params[:time_zone],
                      service_user_id: params[:servicer_id] ? params[:servicer_id] : nil,
                      campaign_uuid: params[:campaign_uuid])
    Attachment.create_attachment(campaign.id,params[:image_path],"Campaign") if params[:image_path]
    share_channel_block(campaign,user,params)
    campaign
  end

  def self.share_channel_block(campaign,user,params)
    short_url(campaign.attachment,params)
    default_footer(user,params) unless params[:is_upload_image]
    update_sms_content(params)
    CampaignDetail.power_share_details(remove_url_from_content(params),campaign)
    CampaignChannel.save_channels(campaign,params)
    user.power_share_status
    approved_campaigns(params,user,campaign) if campaign.status == 'APPROVED'
    campaign.send_business_alert if campaign.status == 'WAITING_FOR_APPROVAL'
  end

  def self.approved_campaigns(params,user,campaign)
    email_process(params,user,campaign)
    sms_process(params,user,campaign)
    social_process(params,user,campaign)
    in_location_process(params,user,campaign)
  end

  def self.edit_campaign(campaign,user,params)
    update_share_detail(user,campaign)
    campaign.campaign_detail.destroy if campaign.campaign_detail
    campaign.campaign_channels.delete_all if campaign.campaign_channels
    delayed_campaigns = Delayed::Job.where(campaign_id: campaign.id)
    delayed_campaigns.destroy_all unless delayed_campaigns.blank?
    params[:share_now] = (params[:share_now] == "false" || !params[:share_now]) ? false : true
    params[:schedule_on] = !params[:share_now] ? params[:schedule_on] : Time.zone.now
    campaign.update_attributes(label: params[:campaign_name],schedule_on: params[:schedule_on], status: params[:campaign_state],time_zone: params[:time_zone])
    campaign.update_revisions
    share_channel_block(campaign,user,params)
    campaign
  end

  def self.update_share_detail(user,campaign)
    email_groups = campaign.email_channels.map(&:contact_group_id)
    sms_groups = campaign.sms_channels.map(&:contact_group_id)
    email_count = email_groups.blank? ? 0  : CustomersContactGroup.email_customers_count(email_groups)
    sms_count = sms_groups.blank? ? 0 : CustomersContactGroup.sms_customers_count(sms_groups)
    ShareDetail.update_campaign_share_detail(user,campaign,email_count,sms_count)
  end

  def self.short_url(attachment,params)
    client = BitLyService.new
    meta_data_img = params[:image_path].nil? ? (params[:og_meta_data] && !params[:og_meta_data][:image].blank? ? params[:og_meta_data][:image] : '') : ''
    params[:image_url] = params[:is_upload_image] ? (attachment.nil? ? meta_data_img : attachment.image.url) : ''
    params[:shorten_url] = client.shorten({url: params[:share_url], secret: ENV['SHORTEN_SECRET']})["short_url"] unless params[:share_url] == "null" || params[:share_url].nil?
    params[:image_shorten_url] = client.shorten({url: params[:image_url], secret: ENV['SHORTEN_SECRET']})["short_url"] if params[:image_url].present?
  end

  def self.remove_url_from_content(params)
    params[:content] = params[:content].gsub("http://inquir.ly/1HFSuj7","#{params[:shorten_url]}") if params[:content] &&  !params[:share_url].blank?
    params
  end

  def self.default_footer(user,params)
    params[:fb_name] = params[:og_meta_data] && !params[:og_meta_data][:title].blank? ? params[:og_meta_data][:title] : user.company.try(:name)
    params[:fb_description] = params[:og_meta_data] && !params[:og_meta_data][:description].blank? ? params[:og_meta_data][:description] : ''
    params[:fb_caption] = fb_caption(user)
    params
  end

  def self.fb_caption(user)
    if user.parent_id == 0
      user.company.try(:name).nil? ? " INQUIRLY | VIA INQUIR.LY" : user.company.try(:name) + " | VIA INQUIR.LY"
    else
      user.client.company.try(:name).nil? ? " INQUIRLY | VIA INQUIR.LY" : user.client.company.try(:name) + " | VIA INQUIR.LY"
    end
  end

  def self.update_sms_content(params)
    if params[:is_power_share] == true && (params[:sms_content].present? || !params[:sms_content].nil?)
      params[:sms_content] = params[:sms_content].gsub("http://inquir.ly/1HFSuj7"," #{params[:shorten_url]}")
    elsif params[:is_power_share] == true && (params[:sms_content].blank? || params[:sms_content].nil?)
      params[:content] = params[:content].gsub("http://inquir.ly/1HFSuj7"," #{params[:shorten_url]}") if params[:content] && !params[:share_url].blank?
      sms = ""
      sms.concat(params[:content] + " ") if params[:content]
      sms.concat(params[:image_shorten_url])  if params[:image_shorten_url] && !sms.include?(params[:image_shorten_url])
      params[:sms_content] = sms
    else
      params[:sms_content] = params[:sms_content].present? ? params[:sms_content].gsub("http://inquir.ly/1HFSuj7"," #{params[:shorten_url]}") : params[:content].gsub("http://inquir.ly/1HFSuj7"," #{params[:shorten_url]}")
    end
    params
  end

  def self.reschedule_share(user,params)
    params[:schedule_on] = params[:share_now] ? Time.zone.now : params[:schedule_on]
    campaign = where(id: params[:id]).first
    campaign.update_attributes(schedule_on: params[:schedule_on])
    delayed_share = Delayed::Job.where(campaign_id: campaign.id, user_id: user.id,failed_at: nil)
    delayed_share.update_all(run_at: params[:schedule_on]) if delayed_share
    inq_campaign = InqCampaign.where(inq_campaign_id: campaign.id).first
    inq_campaign.update_attributes(state: params[:share_now] ? 'ACTIVE' : 'QUEUED', scheduled_on: params[:schedule_on]) if inq_campaign
    scheduled_camp_list(user,params)
  end

  def self.history(user,params)
    campaign_posts(user,params,false)
  end

  def self.scheduled_camp_list(user,params)
    queued_list = Delayed::Job.where(user_id: user.id, failed_at: nil, share_now: false).map(&:campaign_id)
    campaigns = user.campaigns.joins(:inq_campaign).where("inq_campaigns.state = 'QUEUED'").where(id: queued_list).limit(params[:limit].to_i).offset(params[:offset].to_i).order(:id => :desc)
    campaign_collection(campaigns)
  end

  def self.remove_post(user,params)
    campaign = where(id: params[:campaign_id], user_id: user.id).first
    if campaign
      update_share_detail(user,campaign)
      Delayed::Job.where(user_id: user.id, campaign_id: params[:campaign_id],failed_at: nil).delete_all
      inq_campaign = InqCampaign.where(inq_campaign_id: campaign.id).first
      state = CampaignAccess.where(campaign_id: inq_campaign.id).first.try(:destroy)
      inq_campaign.try(:destroy) if state
      campaign.destroy
    end
  end

  def self.campaign_posts(user,params,state)
    queued_list = Delayed::Job.where(user_id: user.id, failed_at: nil).map(&:campaign_id)
    history_campaigns = user.campaigns.joins(:inq_campaign).where("inq_campaigns.state = 'ACTIVE'").where.not(id: queued_list).where(is_archived: state)
    campaigns = history_campaigns.blank? ? [] : where(id: filtered_campaigns(history_campaigns,params)).limit(params[:limit].to_i).offset(params[:offset].to_i).order(:updated_at => :desc)
    campaign_collection(campaigns)
  end

  def self.filtered_campaigns(history_campaigns,params)
    filtered_campaigns = []
    if params[:selected_socials].blank? &&  params[:selected_mobiles].blank? && params[:selected_locations].blank?
      filtered_campaigns << history_campaigns.map(&:id)
    else
      history_campaigns.each do |campaign|
        campaign.campaign_channels.each do | c_channel |
          if c_channel.user_channel && c_channel.user_channel.channel_type == "UserSocialChannel" && params[:selected_socials].split(",").include?(c_channel.user_channel.channel_id.to_s)
            filtered_campaigns << c_channel.campaign_id
          end
          if c_channel.user_channel && c_channel.user_channel.channel_type == "UserMobileChannel" && params[:selected_mobiles].split(",").include?(c_channel.user_channel.channel_id.to_s)
            filtered_campaigns << c_channel.campaign_id
          end
          if c_channel.user_channel && c_channel.user_channel.channel_type == "UserLocationChannel" && params[:selected_locations].split(",").include?(c_channel.user_channel.channel_id.to_s)
            filtered_campaigns << c_channel.campaign_id
          end
        end
      end
    end
    filtered_campaigns.uniq
  end

  def self.campaign_post_info(campaign_id,user)
    campaigns = where(id: campaign_id, user_id: user.id)
    campaigns.blank? ? [] : campaign_collection(campaigns)
  end

  def self.fetch_approval_campaigns(user,params)
    queued_list = Delayed::Job.where(user_id: user.id, failed_at: nil).map(&:campaign_id)
    approval_campaigns = user.campaigns.joins(:inq_campaign).where("inq_campaigns.approval_status = 'WAITING_FOR_APPROVAL'").where.not(id: queued_list)
    campaigns = approval_campaigns.blank? ? [] : approval_campaigns.limit(params[:limit].to_i).offset(params[:offset].to_i).order(:updated_at => :desc)
    campaign_collection(campaigns)
  end

  def self.campaign_collection(campaigns)
    list = []
    campaigns.each do |campaign|
      json = {}
      json["scheduled_on"] = campaign.time_zone ? Time.parse("#{campaign.schedule_on}").in_time_zone(campaign.time_zone) : campaign.schedule_on
      json["campaign_id"] = campaign.id
      json["campaign_uuid"] = campaign.campaign_uuid
      json["campaign_data"] = campaign.campaign_detail ? JSON.parse(campaign.campaign_detail.campaign_data) : {}
      json["is_two_way"] = campaign.two_way_campaign
      json["publisher_id"] = campaign.user_id
      json["servicer_id"] = campaign.service_user_id
      json["social_accounts"] = []
      json["mobile_accounts"] = []
      json["location_accounts"] = []
      campaign.campaign_channels.each do |camp_channel|
        if camp_channel.user_channel && camp_channel.user_channel.channel_type == "UserSocialChannel"
          json1 = {}
          json1["id"] = camp_channel.user_channel.user_social_channel.try(:id)
          json1["name"] = camp_channel.user_channel.user_social_channel.try(:name)
          json1["profile_image"] = camp_channel.user_channel.user_social_channel.try(:profile_image)
          json1["active"] = camp_channel.user_channel.user_social_channel.try(:active)
          json1["channel"] = camp_channel.user_channel.user_social_channel.try(:channel)
          json1["class_name"] = camp_channel.user_channel.user_social_channel.class.try(:model_name).try(:name)
          json["social_accounts"] << json1
        end
        if camp_channel.user_channel && camp_channel.user_channel.channel_type == "UserMobileChannel"
          json2 = {}
          json2["id"] = camp_channel.user_channel.user_mobile_channel.try(:id)
          json2["profile_name"] = contact_group(camp_channel)
          json2["active"] = camp_channel.user_channel.user_mobile_channel.try(:active)
          json2["channel"] = camp_channel.user_channel.user_mobile_channel.try(:channel)
          json2["class_name"] = camp_channel.user_channel.user_mobile_channel.class.try(:model_name).try(:name)
          json["mobile_accounts"] << json2
        end
        if camp_channel.user_channel && camp_channel.user_channel.channel_type == "UserLocationChannel"
          json3 = {}
          json3["id"] = camp_channel.user_channel.user_location_channel.try(:id)
          json3["profile_name"] = camp_channel.user_channel.user_location_channel.channel.name
          json3["active"] = camp_channel.user_channel.user_location_channel.channel.try(:status)
          json3["image"] = qr_image(camp_channel)
          json3["channel"] = camp_channel.user_channel.user_location_channel.channel_type.downcase
          json3["class_name"] = camp_channel.user_channel.user_location_channel.class.model_name.name
          json["location_accounts"] << json3
        end
      end
      json["reach"] = campaign.campaign_activity_stats.blank? ? 0 : campaign.campaign_activity_stats.map(&:reach).sum
      json["views"] = campaign.campaign_activity_stats.blank? ? 0 : campaign.campaign_activity_stats.map(&:views).sum
      list << json
    end
    list
  end

  def self.qr_image(camp_channel)
    camp_channel.user_channel.user_location_channel.channel.try(:image) ? camp_channel.user_channel.user_location_channel.channel.try(:image).url : ''
  end

  def self.contact_group(camp_channel)
    camp_channel.user_channel.user_mobile_channel ? camp_channel.user_channel.user_mobile_channel.contact_group.try(:name) : camp_channel.user_channel.user_mobile_channel.try(:channel)
  end

  protected

  def generate_unique_slug_key
    self.slug = loop do
      random_generate_id = SecureRandom.hex
      break random_generate_id unless self.class.exists?(slug: random_generate_id)
    end
  end

  def update_share_detail_count
    pricing_plan = ShareDetail.get_plan_detail(self.user,self.schedule_on)
    if pricing_plan && pricing_plan.share_detail
      start_date = pricing_plan.start_date.strftime("%Y-%m-%d")
      exp_date = pricing_plan.exp_date.strftime("%Y-%m-%d")
      campaigns_count = self.user.campaigns.where("two_way_campaign is TRUE AND to_char(schedule_on,'YYYY-MM-DD') >= ? AND to_char(schedule_on,'YYYY-MM-DD') <= ?",start_date, exp_date).count
      pricing_plan.share_detail.update_attributes("campaigns_count" => campaigns_count)
    end
  end

  def decrease_campaign_share_count
    pricing_plan = ShareDetail.get_plan_detail(self.user,self.schedule_on)
    if pricing_plan && pricing_plan.share_detail
      pricing_plan.share_detail.update_attributes(campaigns_count: pricing_plan.share_detail.campaigns_count - 1)
    end
  end

end