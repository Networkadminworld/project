require 'spec_helper'

describe Admin::ClientSettingsController do

  before(:each){
    @user = FactoryGirl.create(:user,:default_biz_user, :business_type_id => 2)
    @settings = FactoryGirl.create(:client_setting, user_id: @user.id, pricing_plan_id: @user.business_type_id)
    sign_in :user, @user
  }

  describe "GET user_client_settings" do
    it "should display the user and settings information" do
      xhr :get, :user_client_settings, params = {email: @user.email}, :format => 'js'
      assigns(:user)
      assigns(:settings)
      assigns(:pricing_plans)
    end
  end

  describe "POST update" do
    it "should update the user settings information" do
     patch :update, id: @settings.id, client_setting: {:email_count=> 500, :call_count => 250, :sms_count=> 250, :video_photo_count => 5 , :questions_count => 100, :customer_records_count => 5000, :tenant_count => 5,:id=> @settings.id }
     @settings.email_count == 500
     expect(response).to redirect_to("/admin/client_settings")
    end
  end

	
end