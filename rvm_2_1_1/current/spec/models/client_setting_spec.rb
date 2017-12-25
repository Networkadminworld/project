require "spec_helper"

describe ClientSetting do
  before(:each) {
    @user = FactoryGirl.create(:user,:default_biz_user)
    @pricing_plan = FactoryGirl.create(:pricing_plan, :test_pricing_plan)
    @client_settings = FactoryGirl.create(:client_setting, :client_feature_settings,pricing_plan_id: @pricing_plan.id,user_id: @user.id)
    @client_language =  FactoryGirl.create(:client_language,:test_client_language,language_id: 1,client_setting_id: @client_settings.id)
    @pricing_category_type =  FactoryGirl.create(:pricing_category_type,:test_category_type,pricing_plan_id: @pricing_plan.id,category_type_id: 1)
  }

describe "collect client_settings from DB and format it" do
   it "should be equal to pricing plan hash map" do
   	client_settings = ClientSetting.define_client_settings(@user)
    expect(client_settings).not_to be_empty
end
end
end