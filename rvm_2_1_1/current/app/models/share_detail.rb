class ShareDetail < ActiveRecord::Base

  belongs_to :user
  belongs_to :client_pricing_plan
  has_many :share_summaries

  def self.fetch_active_pricing_plan(user)
    if user.parent_id == 0
      user.active_pricing_plan
    else
      if user.tenant_id
        Tenant.where(id: user.tenant_id).first.try(:active_tenant_plan) || user.client.active_pricing_plan
      else
        user.client.active_pricing_plan
      end
    end
  end

  def self.fetch_active_share_detail(user)
    if user.parent_id == 0
      user.active_pricing_plan.try(:share_detail)
    else
      if user.tenant_id
        active_plan = Tenant.where(id: user.tenant_id).first.try(:active_tenant_plan)
        if active_plan
          active_plan.try(:share_detail)
        else
          user.client.active_pricing_plan.try(:share_detail)
        end
      else
        user.client.active_pricing_plan.try(:share_detail)
      end
    end
  end

  def self.create_share_detail(user,count,column_name,campaign=nil)
    share_detail = campaign ? get_share_detail(user,campaign.schedule_on) : fetch_active_share_detail(user)
    if share_detail
      share_count = count + share_detail.send("#{column_name}")
      share_detail.update_attributes("#{column_name}" => share_count)
      check_share_summary(share_detail,campaign,count,column_name) unless ['campaigns_count','customer_records_count'].include?(column_name)
    end
  end

  def self.check_share_summary(share_detail,campaign,count,column_name)
    summary = ShareSummary.where(campaign_id: campaign.id, share_detail_id: share_detail.id).first
    if summary
      share_count = count + summary.send("#{column_name}")
      summary.update_attributes("#{column_name}" => share_count)
    else
      ShareSummary.create(campaign_id: campaign.id, share_detail_id: share_detail.id, "#{column_name}" => count )
    end
  end

  def self.update_campaign_share_detail(user,campaign,email_count,sms_count)
    share_detail = get_share_detail(user,campaign.schedule_on.strftime("%Y/%m/%d"))
    if share_detail
      summary = ShareSummary.where(campaign_id: campaign.id, share_detail_id: share_detail.id).first_or_initialize
      summary.update_attributes(email_count: email_count, sms_count: sms_count)
      share_detail.update_attributes(email_count: share_detail.email_count - email_count ,sms_count: share_detail.sms_count - sms_count)
    end
  end

  def self.is_share_count_exceeds?(plan,share_detail,share_type,count)
    case share_type
      when 'email'
        share_detail.email_count + count > plan.email_count
      when 'sms'
        share_detail.sms_count + count > plan.sms_count
      when 'campaigns'
        share_detail.campaigns_count + count > plan.campaigns_count
      else
        false
    end
  end

  def self.check_share_counts(user,schedule_date,params={})
    schedule_date = DateTime.parse(schedule_date) unless schedule_date.class == ActiveSupport::TimeWithZone
    plans = user.overall_plans
    if plans.blank?
      error_msg = "You don't have valid pricing plan."
    else
      plan_exp_date = plans.map(&:exp_date).max.strftime("%Y/%m/%d")
      if schedule_date.strftime("%Y/%m/%d") > plan_exp_date
        error_msg = "You don't have valid pricing plan for this schedule date."
      else
        error_msg = share_limit_exceeds(user,plans,schedule_date,params)
      end
    end
    error_msg
  end

  def self.share_limit_exceeds(user,plans,schedule_date,params)
    error_msg = ''
    share_channels, mobile_share_counts = share_channel_list(user,params)
    plans.each do |plan|
      if (plan.start_date..plan.exp_date).cover?(schedule_date)
        campaign_count_exceeds = is_share_count_exceeds?(plan,plan.share_detail,'campaigns',1)
        if campaign_count_exceeds
          error_msg = "You have reached the maximum campaign creation limit."
        else
          msg = ""
          share_channels.each { |channel| msg += " #{channel.upcase}," unless plan.channels_name.include?(channel) }
          if msg == ""
            if share_channels.include?('email') && mobile_share_counts[:email_count] > 0 && is_share_count_exceeds?(plan,plan.share_detail,'email',mobile_share_counts[:email_count])
              msg += "You have reached the maximum email quota of your plan."
            end
            if share_channels.include?('sms') && mobile_share_counts[:sms_count] > 0 && is_share_count_exceeds?(plan,plan.share_detail,'sms',mobile_share_counts[:sms_count])
              msg += "You have reached the maximum sms quota of your plan."
            end
            error_msg = msg
          else
            error_msg = "You are not allowed to share it on these channels:" + msg
          end
        end
      end
    end
    error_msg
  end

  def self.get_share_detail(user,schedule_date)
    share_detail = []
    user.overall_plans.each do |plan|
      share_detail << plan.share_detail if (plan.start_date..plan.exp_date).cover?(schedule_date)
    end
    share_detail.last
  end

  def self.get_plan_detail(user,schedule_date)
    pricing_plan = []
    user.overall_plans.each do |plan|
      pricing_plan << plan if (plan.start_date..plan.exp_date).cover?(schedule_date)
    end
    pricing_plan.last
  end

  def self.share_channel_list(user,params)
    channel_list = []
    mobile_channel_share_count = {}
    mobile_channel_share_count[:email_count] = 0
    mobile_channel_share_count[:sms_count] = 0
    channel_list << UserSocialChannel.where(id: params[:social_channels]).map(&:channel) if params[:social_channels]
    channel_list << UserLocationChannel.where(id: params[:location_channels]).map(&:channel_type) if params[:location_channels]
    if params[:mobile_channels]
      UserMobileChannel.where(id: params[:mobile_channels]).each do |channel|
        channel_list << channel.channel
        mobile_channel_share_count[:email_count] += ContactGroup.all_contacts(user,channel.id,channel.channel) if channel.channel == 'email'
        mobile_channel_share_count[:sms_count] += ContactGroup.all_contacts(user,channel.id,channel.channel) if channel.channel == 'sms'
      end
    end
    [channel_list.flatten.uniq.map(&:downcase),mobile_channel_share_count]
  end

end
