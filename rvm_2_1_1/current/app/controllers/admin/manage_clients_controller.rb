class Admin::ManageClientsController < ApplicationController
  before_action :check_admin_user
  before_filter :get_business_details, only: [:index, :edit, :update]
  before_filter :get_tenant_detail,  only: [:edit_tenant, :update_tenant]
  include ClientWizard
  layout 'admin_layout'
  respond_to :json

  def index
    if params[:search_val].blank?
     @user_lists = User.where(parent_id:0).paginate(:page => params[:page],  :per_page =>20).order("id desc")
    else
      search_val = params[:search_val].gsub(/\s+/, "")
      @user_lists = User.where("parent_id = 0 AND (first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?)","%#{search_val}", "%#{search_val}", "%#{search_val}").paginate(:page => params[:page],  :per_page => 25).order("id desc")
    end
  end
  
  def update
    if User.update_service_user(@user,params)
      if @user.parent_id == 0
        redirect_to admin_manage_clients_path
      else
        redirect_to admin_manage_client_show_users_path(@user.parent_id)
      end
    else
      render :edit
    end
  end  
    
  def show
    user = User.where(id: params[:id]).first
    @share_detail = user.parent_id == 0 ? user.share_detail : user.client.share_detail 
  end 

  def change_client_status
    user_status = User.change_status(params)
    render :json => {status: 200, message: "Success", is_active: user_status}
  end

  def show_users
    @client_users = User.where(parent_id: params[:manage_client_id]).paginate(:page => params[:page], :per_page =>20)
  end

  def show_tenants
    @tenants = Tenant.where(client_id: params[:manage_client_id]).paginate(:page =>params[:page],:per_page =>20)
  end 

  def get_business_details
    @user = User.where(id: params[:id]).first if params[:action] == 'edit' || params[:action] == 'update'
    @roles = Role.all
  end

  def get_tenant_detail
    @tenant = Tenant.where(id: params[:manage_client_id]).first
  end
  
  def update_tenant
    if Tenant.update_tenant_info(@tenant,params)
      redirect_to admin_manage_client_show_tenants_path(@tenant.client_id)
    else
      render :edit_tenant
    end
  end

  def download_client_detail
    @client = User.where(id:params[:manage_client_id]).first
    @client_users = @client.users
    @tenants = @client.tenants
    @share_detail =  @client.parent_id == 0 ? @client.active_pricing_plan.try(:share_detail) :  @client.client.active_pricing_plan.try(:share_detail)
    respond_to do  |format|
      format.html
      format.pdf do
        render pdf: "report",
        layout: "pdf.html",
        template: "admin/manage_clients/download_client_detail.pdf.erb",
        margin: {top: 2,bottom: 0},
        page_height: '5in',
        page_width: '7in'
      end
    end
  end

end

  