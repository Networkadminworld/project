require 'spec_helper'
require 'factory_girl_rails'

##
# Since payments stuff are not truly defined,
# we are just seeing if certain actions exists
describe TenantsController do
  # include Devise::TestHelpers
  before(:each){
    User.delete_all
    Role.delete_all
    @role = FactoryGirl.create(:role,:first_plan)
    @pricing_plan = PricingPlan.where(plan_name: "Solo").first
    @user = FactoryGirl.create(:user,:default_user,:role_id => @role.id,:authentication_token => "8982jd9sjdskd02ejskdsdoj",:business_type_id => @pricing_plan.business_type_id.to_i )
    @tenant = FactoryGirl.create(:tenant, :client_id => @user.id)
    @tenant_build = FactoryGirl.build(:valid_tenant)
    controller.stub(:check_admin_user).and_return(@user)
    controller.stub(:check_listener_module).and_return(true)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)
    controller.stub(:check_role_level_permissions).and_return(true)
    controller.stub(:check_tenant_limit).and_return(true)
    @controller.stub(:current_user) { @user }
  }
	
	describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response.status).to eq(200)
    end
    
    it "renders the index template for check valid user" do
    @user.company_name = nil
    @user.save(:validate => false)
    expect(controller).to receive(:check_valid_user).and_call_original
      get :index
      response.should redirect_to "/users/edit"
    end    
  end
  
describe 'Active the tenant' do
  it "sholud active the teanant" do
    post :change_tenant_status, tenant_id: @tenant.id, is_active: "false"
    parsed_body = JSON.parse(response.body)
    parsed_body["is_active"].should == false
    expect(response.status).to eq(200)
  end
   it "sholud not active the teanant" do
    post :change_tenant_status, tenant_id: @tenant.id, is_active: "true"
    parsed_body = JSON.parse(response.body)
    parsed_body["is_active"].should == true
    expect(response.status).to eq(200)
  end
end

end


