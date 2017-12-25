class Tenant < ActiveRecord::Base
  belongs_to :user
  belongs_to :tenant_region
  belongs_to :tenant_type
  has_many :client_pricing_plans, as: :client
  after_create :map_tenant_with_client

  validates :name, :presence => {:message => "Please enter tenant name."}
  validates :name, :uniqueness => {:scope => :client_id, :message => "Tenant already exists."}

  has_attached_file :logo,
                    :styles => { medium: "300x300>", thumb: "100x100>" },
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => ENV['AWS_BUCKET'],
                        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    }
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def map_tenant_with_client
    ExecutiveTenantMapping.create(user_id: self.client_id, tenant_id: self.id, is_active: true)
  end

  def self.get_tenant_list(user,search_text)
    if search_text.blank?
      user.parent_id != 0 && user.tenant_id ? where(id: user.tenant_id) :
          where(client_id: user.parent_id == 0 ? user.id : user.parent_id)
    else
      searched_tenant_locations(user,search_text)
    end
  end

  def self.change_tenant_status(params)
    tenant = where(id: params[:tenant_id]).first
    status = tenant.update_attributes(is_active: params[:is_active])
    update_users_status(tenant,tenant.is_active) if status
    tenant.is_active
  end

  def self.update_users_status(tenant,status)
    users = User.where(tenant_id: tenant.id)
    users.update_all(is_active: status)
  end

  def self.tenant_list(user,per_page,search_text)
    if search_text.blank?
      user.parent_id != 0 && user.tenant_id ? where(id: user.tenant_id, client_id: user.parent_id).limit(per_page.to_i) :
          where(client_id: user.parent_id == 0 ? user.id : user.parent_id).limit(per_page.to_i)
    else
      searched_tenant_list(user,per_page,search_text)
    end
  end

  def self.searched_tenant_list(user,per_page,term)
    if user.parent_id != 0 && user.tenant_id
      query_method(user.parent_id == 0 ? user :  user.client,term).where(tenant_id: user.tenant_id).limit(per_page.to_i)
    else
      query_method(user.parent_id == 0 ? user :  user.client,term).limit(per_page.to_i)
    end
  end

  def self.searched_tenant_locations(user,term)
    if user.parent_id != 0 && user.tenant_id
      query_method(user.parent_id == 0 ? user :  user.client,term).where(tenant_id: user.tenant_id)
    else
      query_method(user.parent_id == 0 ? user :  user.client,term)
    end
  end

  def self.selected_regions(user,params)
    client = user.parent_id == 0 ? user :  user.client
    if !params[:tenant_region_id].nil? && !params[:tenant_region_id].blank? && params[:tenant_region_id] != "0"
      user.parent_id != 0 && user.tenant_id ? where(id: user.tenant_id, tenant_region_id: params[:tenant_region_id],client_id: client.id, is_active: true) :
          where(tenant_region_id: params[:tenant_region_id],client_id: client.id, is_active: true)
    else
      where(client_id: client.id, is_active: true)
    end
  end

  def users
    User.where(tenant_id: self.id)
  end

  def company_profile_img
    company_info && company_info.attachment ? company_info.attachment.image.url(:square) : ''
  end

  def company_info
    Company.where(user_id: self.client_id).first
  end

  def logo_url
    self.logo && self.logo.url != "/logos/original/missing.png" ? self.logo.url : ''
  end

  def region
    TenantRegion.where(id: self.tenant_region_id).first.try(:name)
  end

  def type
    TenantType.where(id: self.tenant_type_id).first.try(:name)
  end

  def self.query_method(client,term)
    Tenant.eager_load(:tenant_region, :tenant_type)
      .where("(tenants.name ILIKE ? OR tenants.address ILIKE ? OR tenants.email ILIKE ? OR tenant_regions.name ILIKE ? OR tenant_types.name ILIKE ?) AND client_id= ? ", "%#{term}%","%#{term}%","%#{term}%","%#{term}%","%#{term}%",client.id)
  end

  def self.update_tenant_info(tenant,params)
    tenant.update_attributes(name: params[:tenant_name], address: params[:tenant_address])
  end

  def self.active_client_tenant_plan(client,type)
    if type == 'tenant'
      active_pricing_plan = client.active_tenant_plan
      channels = active_pricing_plan ? Channel.where(id: active_pricing_plan.pricing_plan_channels.map(&:channel_id)).map(&:id) : []
    else
      active_pricing_plan = client.active_pricing_plan
      channels = active_pricing_plan ? Channel.where(id: active_pricing_plan.pricing_plan_channels.map(&:channel_id)) : []
    end
    [active_pricing_plan, channels]
  end

  def self.save_tenant_plan(params,client)
    tenant_plan = ClientPricingPlan.where(client_id: params[:tenant_id], client_type: "Tenant").first_or_initialize
	tenant_plan.save()
    tenant_plan.create_or_update_channel_list(params[:channels_id])
    params.delete :tenant_id
    params.delete :client_pricing_plan_id
    params.delete :channels_id
    plan = client.active_pricing_plan
    if params[:email_count] <= (plan.email_count || 0) && params[:sms_count] <= (plan.sms_count || 0) && params[:customer_records_count] <= (plan.customer_records_count || 0) &&
        params[:campaigns_count] <= (plan.campaigns_count || 0) && params[:fb_boost_budget] <= (plan.fb_boost_budget || 0) && params[:total_reach] <= (plan.fb_boost_budget || 0)
      tenant_plan.update_attributes(params)
      update_client_pricing_plan(params,plan)
    else
      {error: "You can't set the limit more than the client plan" }
    end
  end

  def self.update_client_pricing_plan(params, plan)
    plan.update_attributes(email_count: (plan.email_count || 0) - params[:email_count],
                           sms_count: (plan.sms_count || 0) - params[:sms_count],
                           customer_records_count: (plan.customer_records_count || 0) - params[:customer_records_count],
                           campaigns_count: (plan.campaigns_count || 0) - params[:campaigns_count],
                           fb_boost_budget: (plan.fb_boost_budget || 0) - params[:fb_boost_budget],
                           total_reach: (plan.total_reach || 0) - params[:total_reach])
  end

  def active_tenant_plan
    ClientPricingPlan.where(client_id: self.id, client_type: 'Tenant', is_active: true).first
  end
end
