require 'spec_helper'

##
# Since payments stuff are not truly defined,
# we are just seeing if certain actions exists
describe PaymentsController do
  # include Devise::TestHelpers
  before(:each){
    User.delete_all
    @role = Role.find_by(:name => "Individual")
    @pricing_plan = PricingPlan.where(plan_name: "Solo").first
    @user = FactoryGirl.create(:user,:default_user,:role_id => @role.id,:authentication_token => "8982jd9sjdskd02ejskdsdoj",:business_type_id => @pricing_plan.business_type_id.to_i )
    controller.stub(:check_admin_user).and_return(@user)
    controller.stub(:check_listener_module).and_return(true)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)
    controller.stub(:check_role_level_permissions).and_return(true)    
    @controller.stub(:current_user) { @user }
  }
end

def access_code(params,pricing_plan,user)
  @pricing_plan = PricingPlan.find_by_id(pricing_plan.id)
  params["merchant_id"] =  ENV["CCAVENUE_MERCHANT_ID"]
  params["order_id"] = "898sdskdjsd"
  params["amount"] = (pricing_plan.amount * 12).to_s
  params["currency"] = "INR"
  params["redirect_url"] = ENV["CCAVENUE_REDIRECT_URL"]
  params["cancel_url"] = ENV["CCAVENUE_CANCEL_URL"]
  params["language"] = "EN"
  params["billing_ name"] = user.first_name
  merchantData=""
  working_key= ENV["CCAVENUE_WOKING_KEY"] #Put in the 32 Bit Working Key provided by CCAVENUES.
  access_code= ENV["CCAVENUE_ACCESS_CODE"]   #Put in the Access Code in quotes provided by CCAVENUES.

  params.each do |key,value|
    merchantData += key+"=" + "#{value}" + "&"
  end

  #encrypted_data = Base64.encode64("#{merchantData},#{working_key}")

  crypto = Crypto.new
  encrypted_data = crypto.encrypt(merchantData,working_key)
  return encrypted_data,access_code
end

