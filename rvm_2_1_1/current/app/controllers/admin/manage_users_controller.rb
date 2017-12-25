class Admin::ManageUsersController < ApplicationController
  before_action :check_admin_user
  before_filter :authenticate_user_web_api
  before_filter :get_business_details, only: [:new, :create, :index, :edit, :update]
  layout 'admin_layout'
  respond_to :json

  def index
    @service_users = user_list(User.where(parent_id: current_user.id))
  end

  def new
    @user = User.new
  end

  def create
    @user,password,admin = User.create_service_user(user_params)
    respond_to do |format|
      if @user.save
        @user.update_businesses(params)
        InviteUser.corporate_user_confirmation(@user,admin.email,password).deliver
        format.html { redirect_to admin_users_path, notice: 'User successfully created.' }
        format.json { render json: 200 }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if User.update_service_user(@user,user_params,params[:businesses])
        format.html { redirect_to admin_users_path, notice: 'User successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    user_status = User.change_status(params)
    render :json => {status: 200, message: "Success", is_active: user_status}
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :mobile, :role_id, :parent_id)
  end

  def user_list(users)
    list = []
      users.includes(:role).includes(:executive_business_mappings).each do |user|
        json = {}
        json["id"] = user.id
        json["first_name"] = user.first_name
        json["last_name"] = user.last_name
        json["email"] = user.email
        json["mobile"] = user.mobile
        json["is_active"] = user.is_active
        json["role_id"] = user.role_id
        json["businesses"] = user.executive_business_mappings.map(&:company_name).join(",")
        json["role_name"] = user.role.try(:name)
        json["status"] = user.is_active
        list << json
      end
    list
  end

  def get_business_details
    @user = User.where(id: params[:id]).first if params[:action] == 'edit' || params[:action] == 'update'
    @roles = Role.where(name: ["Customer-Service-Executive", "Inq-Test-User"], is_default: true)
    @all_businesses = Company.business_list
  end

end