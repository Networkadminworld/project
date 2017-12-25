class ClientPricingPlan < ActiveRecord::Base
  belongs_to :pricing_plan
  has_one :share_detail, :dependent => :destroy
  has_many :pricing_plan_channels, as: :plannable
  belongs_to :client, polymorphic: true

  after_create :create_share_detail

  def create_or_update_channel_list(channels_id)
    PricingPlanChannel.where(plannable_id: self.id).delete_all
    channels_id && channels_id.each do |channel_id|
      PricingPlanChannel.create(plannable_type: self.class.try(:model_name).try(:name), plannable_id: self.id, channel_id: channel_id)
    end
  end

  def self.save_client_plan(params)
    date_list = get_start_end_date(params)
    plan = PricingPlan.where(id: params[:id]).first
    user = User.where(id: params[:client_id]).first
    user.client_pricing_plans.update_all(is_active: false) if user.is_trial_user?
    date_list.each do |list|
      client_plan = new(client_id: params[:client_id], client_type: params[:client_type], email_count: plan.email_count, sms_count: plan.sms_count,
      customer_records_count: plan.customer_records_count, campaigns_count: plan.campaigns_count, fb_boost_budget: plan.fb_boost_budget,
      pricing_plan_id: plan.id, is_active: Date.parse("#{list[:start_date]}") == Date.today, start_date: list[:start_date], exp_date: list[:end_date])
      if client_plan.save
        client_plan.create_or_update_channel_list(plan.pricing_plan_channels.map(&:channel_id))
      end
    end
    update_user_status(user,params[:start_date],params[:action]) if params[:client_type] == 'User'
  end

  def self.update_user_status(user,start_date,action)
    user.is_active = Date.parse(start_date) == Date.today if action == 'New'
    user.exp_date = user.client_pricing_plans.map(&:exp_date).max
    user.save(validate: false)
  end


  def self.get_start_end_date(params)
    dates = []
    (1..params[:end_months].to_i).each do |month|
      list = {}
      list[:start_date] = month == 1 ? Date.parse(params[:start_date]) : (Date.parse(params[:start_date]) + (month - 1).months)
      list[:end_date] = (Date.parse(params[:start_date]) + month.months) - 1
      dates << list
    end
    dates
  end

  def channels_name
    Channel.where(id: self.pricing_plan_channels.map(&:channel_id)).map(&:name)
  end

  def expiry_date
    if self.client_type == 'User'
      user = User.where(id: self.client_id).first
    else
      tenant = Tenant.where(id: self.client_id).first
      user = User.where(id: tenant.client_id).first
    end
    user.client_pricing_plans.map(&:exp_date).max
  end

  private

  def create_share_detail
   ShareDetail.create(customer_records_count: 0, sms_count: 0, email_count: 0, campaigns_count: 0, fb_boost_budget: 0, total_reach: 0,
                      is_current: true, client_pricing_plan_id: self.id)
  end
end