class PricingPlan < ActiveRecord::Base
  has_many :pricing_plan_channels, as: :plannable
  belongs_to :currency

  validates :name, presence: {:message => "Please enter plan name."}
  validates :name, uniqueness: {:scope => :country, :message => "Plan already exists."}

  def create_or_update_channel_list(channels_id)
    PricingPlanChannel.where(plannable_id: self.id).delete_all
    channels_id && channels_id.each do |channel_id|
      PricingPlanChannel.create(plannable_type: self.class.try(:model_name).try(:name), plannable_id: self.id, channel_id: channel_id)
    end
  end

  def update_pricing_details(params,channels_id)
    ok = self.update_attributes(params)
    ok && channels_id ? self.create_or_update_channel_list(channels_id) : ok
  end

  def self.fetch_client_config(params)
    user = User.where(id: params[:client_id]).first
    response = {}
    unless user.overall_plans.blank?
      if user.parent_id == 0
        plan = user.active_pricing_plan
      else
        if user.tenant_id
          tenant = Tenant.where(id: user.tenant_id).first
          plan = tenant.present? ? tenant.active_tenant_plan : []
        else
          plan = user.client.active_pricing_plan
        end
      end
      unless plan.blank?
       response[:plan_detail] = plan ? JSON.parse(plan.to_json(:except => [:created_at, :updated_at, :exp_date], :methods => [:expiry_date])) : {}
       response[:channels] = plan.pricing_plan_channels ? Channel.where(id: plan.pricing_plan_channels.map(&:channel_id)).map(&:name) : []
      end
    end
    response.blank? ?  {status: 400, error: "You don't have valid pricing plan set. Please contact admin for subscription."} : {status: 200, response: response }
  end

  def channels_name
    Channel.where(id: self.pricing_plan_channels.map(&:channel_id)).map(&:name)
  end

end