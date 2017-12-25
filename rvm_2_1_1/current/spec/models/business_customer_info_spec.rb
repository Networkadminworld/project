require "spec_helper"
include ActionDispatch::TestProcess
describe BusinessCustomerInfo do

  before(:each) do
    @biz_user = FactoryGirl.create(:user, :default_biz_user)
    @biz_customer_info = FactoryGirl.create(:business_customer_info, user: @biz_user)
  end

 describe "#Association" do
	it { should belong_to(:user) }  
  end

 describe "#validation" do
	it { should validate_uniqueness_of(:email).scoped_to(:user_id) }
  end

  describe "self.check_user_already_exist" do
    it "must return true for already existing business customer info" do
      info_present = BusinessCustomerInfo.check_user_already_exist(@biz_customer_info.email,
        @biz_customer_info.customer_name,
        @biz_user.id)
      expect(info_present).to eq(true)
    end

    it "must return false for unknown email" do
      info_present = BusinessCustomerInfo.check_user_already_exist("unknown@gmail.com",
        @biz_customer_info.customer_name,
        @biz_user.id)
      expect(info_present).to eq(false)
    end

    it "must return false for unknown customer name" do
      info_present = BusinessCustomerInfo.check_user_already_exist(@biz_customer_info.email,
        "unknon name",
        @biz_user.id)
      expect(info_present).to eq(false)
    end

    it "must return false for unown business user id" do
      unknown_id = BusinessCustomerInfo.maximum(:id) + 1
      info_present = BusinessCustomerInfo.check_user_already_exist(@biz_customer_info.email,
        @biz_customer_info.customer_name,
        unknown_id)
      expect(info_present).to eq(false)
    end
  end

  # Should be discussed with implementers before writing these tests
  describe "self.insert_customer_info" do
    it "must add business customer info if right array is passed" do
      BusinessCustomerInfo.delete_all
      csv_file = fixture_file_upload('/business_customer_info.csv')
      FactoryGirl.create(:client_setting, :client_feature_settings, pricing_plan_id: PricingPlan.where(plan_name: "Enterprise").first.id, user_id: @biz_user.id)
      FactoryGirl.create(:share_detail, user_id: @biz_user.id)
      BusinessCustomerInfo.insert_customer_info( csv_file, @biz_user)
      expect(BusinessCustomerInfo.count).to eq(1)
    end
    it "must add business customer info if wrong array is passed" do
      BusinessCustomerInfo.last.update_attributes(:is_deleted => false)
      FactoryGirl.create(:business_customer_info, email: "inquirlytest@gmail.com", mobile: "9876543211", user: @biz_user, is_deleted: true)
      csv_file = fixture_file_upload('/business_customer_info_with_wrongdetails.csv')
      FactoryGirl.create(:client_setting, :client_feature_settings, pricing_plan_id: PricingPlan.where(plan_name: "Enterprise").first.id, user_id: @biz_user.id)
      FactoryGirl.create(:share_detail, user_id: @biz_user.id)
      BusinessCustomerInfo.insert_customer_info( csv_file, @biz_user)
      expect(BusinessCustomerInfo.count).to eq(4)
    end    
  end
  
  describe "self.build_business_customer_json" do
    it "business customer records as json if the data passed" do
      params = {:page => 1,:per_page => 10 }
      result = BusinessCustomerInfo.build_business_customer_json(@biz_user,params)
      expect(result).not_to be_blank
    end
    it "business customer records as json if the data not passed" do
      params = {:page => 1,:per_page => 10 }
      result = BusinessCustomerInfo.build_business_customer_json(@biz_user,params)
      expect(result["value"]).to be_blank
    end    
  end
end