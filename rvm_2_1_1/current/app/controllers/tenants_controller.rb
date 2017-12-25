class TenantsController < ApplicationController
  before_action :set_tenant, only: [:update]
  skip_before_filter :authenticate_user_web_api, only: :create_tenant

  def index
    tenants = Tenant.tenant_list(current_user,params[:per_page],params[:search_text])
    @tenants = tenants.paginate(:page => params[:page],:per_page => params[:per_page]).order('tenants.id DESC')
    render :json => { tenants_list: build_tenant_list(@tenants), tenant_regions: current_user.tenant_regions,tenant_types: current_user.tenant_types,client_id: current_user.id }
  end

  def create
    @tenant = Tenant.new(tenant_params)
    if @tenant.save
      set_client.add_tenant_status
      render :json => { status: 200 }
    else
      render :json => { errors: @tenant.errors, status: :unprocessable_entity }
    end
  end

  def update
    updated_params = @tenant.logo.url == tenant_params["logo"] ? tenant_params.except!("logo") : tenant_params
    if @tenant.update(updated_params)
      render :json => { status: 200 }
    else
      render :json => { errors: @tenant.errors, status: :unprocessable_entity }
    end
  end

  def change_tenant_status
    tenant_status = Tenant.change_tenant_status(params)
    render :json => {status: 200, message: "Success", is_active: tenant_status}
  end

  def load_geo_details
    tenants = Tenant.get_tenant_list(current_user,params[:search_text])
    company_info = { lat: 12.971599, long: 77.594563 }
    if current_user.company && current_user.company.try(:lat) && current_user.company.try(:lng)
      company_info = { lat: current_user.company.try(:lat), long: current_user.company.try(:lng) }
    end
    geo_list = []
    tenants.each do |tenant|
      obj = {
          name: tenant.name,
          address: tenant.address,
          lat: tenant.lat,
          long: tenant.lng
      }
      geo_list << obj
    end
    render :json => [geo_list,company_info]
  end

  def create_tenant
    client = User.where(email: params[:admin_email]).first.try(:id)
    if client
      tenant = Tenant.new(name: params[:name], address: params[:address],client_id: client, is_active: true)
      response = tenant.save ? { status: 200 } : { errors: tenant.errors, status: :unprocessable_entity }
    else
      response = { status: 400, message: "Invalid client email"}
    end
    render :json => response
  end

  def create_region
    render :json => TenantRegion.create_new(set_client,tenant_config_params,params[:description])
  end

  def create_type
    render :json => TenantType.create_new(set_client,tenant_config_params,params[:description])
  end

  def get_client_plan
    render :json => Tenant.active_client_tenant_plan(set_client,'client')
  end

  def save_tenant_plan
    render :json => Tenant.save_tenant_plan(tenant_plan_params,set_client)
  end

  def get_tenant_plan
    render :json => Tenant.active_client_tenant_plan(set_tenant,'tenant')
  end

  private

  def tenant_params
    params.require(:tenant).permit(:id,:name, :address, :email, :phone, :contact_number, :tenant_type_id,
                                   :tenant_region_id, :website_url, :facebook_url, :linkedin_url, :twitter_url,
                                   :client_id, :redirect_url, :lat, :lng, :logo).merge!(client_id: current_user.parent_id == 0 ? current_user.id : current_user.parent_id)
  end

  def tenant_config_params
    params.require(:tenant).permit(:name,:description).merge(user_id: current_user.parent_id == 0 ? current_user.id : current_user.parent_id)
  end

  def tenant_plan_params
    params.require(:tenant_plan).permit(:tenant_id, :client_pricing_plan_id, :email_count, :sms_count, :customer_records_count,
                                        :campaigns_count, :fb_boost_budget, :total_reach, :start_date, :exp_date, :pricing_plan_id,
                                        :is_active, :channels_id => [])
  end

  def set_tenant
    @tenant = Tenant.where(id: params[:id]).first
  end

  def set_client
    current_user.parent_id == 0 ? current_user : current_user.client
  end

  def build_tenant_list(tenants)
    list = {}
    list["tenants_list"] = tenants.collect{ |i| i.as_json(:except => [:created_at, :updated_at], :methods => [:logo_url,:region,:type]) }
    list["num_results"] = tenants.count
    list
  end
end
