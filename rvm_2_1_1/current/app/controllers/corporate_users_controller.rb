class CorporateUsersController < ApplicationController
  before_action :set_corporate_user, only: [:update]
  before_action :tenant_details, except: [:create_user,:reset_user_password]

  def index
    corporate_users = User.user_list(current_user,params[:per_page],params[:search_text]).where.not(id: current_user.id)
    @corporate_users = corporate_users.paginate(:page => params[:page],:per_page => params[:per_page]).order('id DESC')
    render :json => { users_list: build_user_list(@corporate_users), roles: @roles, tenants: @tenants,tenant_region_id: current_user.tenant_region,
                      currencies: Currency.all.to_json,parent_id: current_user.parent_id == 0 ? current_user.id : current_user.parent_id, tenant_id: current_user.tenant_id }
  end

  def create
    @corporate_user, password,admin = User.create_corp_user(corporate_user_params)
    if @corporate_user.save
      current_user.add_user_status
      InviteUser.corporate_user_confirmation(@corporate_user,admin.email,password).deliver
      render :json => { status: 200 }
    else
      render :json => { errors: @corporate_user.errors, status: :unprocessable_entity }
    end
  end

  def update
    if User.update_corp_user(@corporate_user,corporate_user_params)
      render :json => { status: :ok }
    else
      render :json => { errors: @corporate_user.errors, status: :unprocessable_entity }
    end
  end

  def change_user_status
    user_status = User.change_status(params)
    render :json => {status: 200, message: "Success", is_active: user_status}
  end

  def reset_password
    user = User.reset_user_password(params)
    render :json => {status: user.errors.blank? ? 200 : 400, errors: user.errors, message: user.is_active? ? "New password emailed to user #{user.first_name}" : "#{user.first_name} password has been changed"}
  end

  def create_user
    params[:jb_user] = true
    if params[:is_update]
      @corporate_user = User.where(email: params[:old_email].downcase).first
      if @corporate_user
        render :json => User.update_corp_user(@corporate_user,params) ? { status: 200 } : { errors: @corporate_user.errors, status: :unprocessable_entity }
      else
        render :json => { errors: "User not found", status: :unprocessable_entity }
      end
    else
      @corporate_user, password,admin = User.create_corp_user(params)
      if @corporate_user.save
        InviteUser.corporate_user_confirmation(@corporate_user,admin.email,password).deliver
        render :json => { status: 200 }
      else
        render :json => { errors: @corporate_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def reset_user_password
    user = User.reset_password(params)
    render :json => {status: 200, message: user.is_active? ? "New password emailed to user #{user.first_name}" : "#{user.first_name} password has been changed"}
  end

  def load_regions
    render :json => build_regions
  end

  def load_tenants
    render :json => Tenant.selected_regions(current_user, params)
  end

  private

  def set_corporate_user
    @corporate_user = User.find_by(id: params[:id])
    redirect_to corporate_users_path, :flash => { :notice => "#{APP_MSG['authorization']['failure']}" } if @corporate_user.blank?
  end

  def tenant_details
    @tenants = Tenant.get_tenant_list(current_user,'').collect{|a| [a.name,a.id] if a.is_active}.compact
    @roles = Role.client_roles(current_user).collect {|b| [b.name, b.id,b.is_default]}.compact
  end

  def check_tenant
    tenant = Tenant.where(client_id: (current_user.parent_id != 0 && current_user.parent_id != nil ? current_user.parent_id : current_user.id))
    redirect_to tenants_url, notice: "#{APP_MSG["tenant"]["present"]}" if tenant.blank?
  end

  def corporate_user_params
    params.require(:user).permit!
  end

  def build_regions
    list = []
    if current_user.parent_id != 0 && current_user.tenant_id
      regions = current_user.tenant_regions.where(id: current_user.tenant_region)
    else
      list << { id: 0, name: 'all', user_id: current_user.id } unless current_user.tenant_regions.blank?
      regions = current_user.tenant_regions
    end
    regions.each do |region|
      json = {}
      json["id"] = region.id
      json["name"] = region.name
      json["user_id"] = region.user_id
      list << json
    end
    list
  end

  def build_user_list(users)
    list = {}
    list["users_list"] = []
    users.each do |user|
      json = {}
      json["id"] = user.id
      json["first_name"] = user.first_name
      json["last_name"] = user.last_name
      json["email"] = user.email
      json["mobile"] = user.mobile
      json["is_active"] = user.is_active
      json["tenant_id"] = user.tenant_id
      json["role_id"] = user.role_id
      json["tenant"] = user.tenant.try(:name)
      json["tenant_region"] = user.tenant_region
      json["currency_id"] = user.currency_id
      json["profile_image"] = user.avatar && !user.default_url? ? user.avatar.url(:thumb) : ''
      json["role"] = user.role.try(:name)
      list["users_list"] << json
    end
    list["num_results"] = users.count
    list
  end
end
