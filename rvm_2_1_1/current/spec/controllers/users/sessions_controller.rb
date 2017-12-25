require 'spec_helper'

describe Users::SessionsController do
  include Devise::TestHelpers
  before(:each){
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = FactoryGirl.create(:user,:default_biz_user)

    @pricing_plan = FactoryGirl.create(:pricing_plan, :test_pricing_plan)
    @client_settings = FactoryGirl.create(:client_setting, :client_feature_settings,pricing_plan_id: @pricing_plan.id,user_id: @user.id)
    @client_language =  FactoryGirl.create(:client_language,:test_client_language,language_id: 1,client_setting_id: @client_settings.id)
    @pricing_category_type =  FactoryGirl.create(:pricing_category_type,:test_category_type,pricing_plan_id: @pricing_plan.id,category_type_id: 1)

    controller.stub(:current_user){@user}
    sign_in :user, @user
    controller.stub(:check_admin_user).and_return(@user)
    controller.stub(:check_listener_module).and_return(true)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)

  }

  describe "collect client_settings from DB and format it" do
   it "should be equal to client_settings hash" do
    client_settings = ClientSetting.define_client_settings(@user)
    expect($client_settings).to eq(client_settings)
   end
  end

  describe "Add one more language to client settings" do
   it "should reflect in client setting hash " do
    @user.client_setting.update_attributes(language_ids:["1","2"])
    client_settings = ClientSetting.define_client_settings(@user)
    expect($client_settings).to eq(client_settings)
   end
  end



  describe "User - Category types" do
   it "Application level settings should override the client settings" do
     categories = ClientSetting.get_current_user_settings(COLUMN_NAME[:categories],@user)
     expect(categories).to eq([1])
   end
 end

 describe "change language count in client settings" do
   it "Client settings should override the application level settings in pricing plan" do
     @client_settings.update_attributes(tenant_count: 4)
     count = ClientSetting.get_current_user_settings(COLUMN_NAME[:tenants],@user)
     expect(count).to eq(4)
   end
 end

end

