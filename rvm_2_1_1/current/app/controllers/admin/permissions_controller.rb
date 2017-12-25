class Admin::PermissionsController < ApplicationController
  before_action :check_admin_user
  before_filter :authenticate_user_web_api
  layout 'admin_layout'
  include FeaturePermissions

  def index
    @roles = Role.where(user_id: nil).paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    respond_to do |format|
      if @role.save
        format.html { redirect_to admin_permissions_path, notice: 'Role was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, :profile, :is_default)
  end

end


