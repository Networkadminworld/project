class Admin::ClientSettingsController < ApplicationController
  layout 'admin_layout'
  before_action :check_admin_user
  before_filter :authenticate_user_web_api

  def user_client_settings
    @user = User.where(email: params[:email]).first
    @settings = ClientSetting.where(user_id: @user.id).first if @user
    @pricing_plan = PricingPlan.where(id: @settings.pricing_plan_id).first if @settings
  end

  def update
   settings = ClientSetting.where(id: params[:client_setting][:id]).first
   if settings.update_attributes(settings_params)
      redirect_to admin_client_settings_path, notice: APP_MSG['admin']['settings_update']
   end
  end

  private

  def settings_params
    params.require(:client_setting).permit(:email_count,:call_count, :sms_count, :video_photo_count, :questions_count, :customer_records_count, :tenant_count, :id)
  end


  def check_admin_user
    redirect_to "/" if current_user && !current_user.admin?
  end

end
