class ManageRolesController < ApplicationController
  before_filter :authenticate_user_web_api
  respond_to :json
  before_action :client_user, only: [:create, :update]

  def index
    render :json => Role.client_roles(current_user)
  end

  def create
    render :json => Role.create_role(client_user,role_params)
  end

  def update
    render :json => Role.update_role(client_user,role_params.merge(id: params[:id]))
  end

  def update_permissions
    render :json => Permission.update_permissions(params)
  end

  def role_permissions
    render :json => Permission.role_permissions(params)
  end

  private

  def role_params
    params.require(:manage_role).permit(:name, :profile, :visible_to_tenant)
  end

  def client_user
    current_user.parent_id == 0 ? current_user.id : current_user.parent_id
  end


end