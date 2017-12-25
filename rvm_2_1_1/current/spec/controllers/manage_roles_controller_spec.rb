require "spec_helper"
require 'factory_girl_rails'


describe ManageRolesController do
		  before(:each){
    User.delete_all
    Role.delete_all
    @pricing_plan = PricingPlan.where(plan_name: "Business").first
		@role = FactoryGirl.create(:role,:first_plan)
    @user = FactoryGirl.create(:user,:default_user,:role_id => @role.id,:authentication_token => "8982jd9sjdskd02ejskdsdoj",:business_type_id => @pricing_plan.business_type_id.to_i,:parent_id => 0 )
		@role = FactoryGirl.create(:role,:test_role,:user_id => @user.id)
    controller.stub(:check_admin_user).and_return(@user)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)
    controller.stub(:check_role_level_permissions).and_return(true)
    controller.stub(:check_tenant).and_return(true)
    #controller.stub(:set_corporate_user).and_return(@user)
    controller.stub(:current_user) { @user }
  }
	describe "GET index" do
    it "assigns @roles" do
     get :index 
     assigns(:roles).should eq([@role])
   end
   
	it "renders the index template" do
		 get :index
		expect(response.status).to eq(200)
	 end
 end
 
 describe "GET #new" do 
  it "build new object for role" do 
    get :new
      assigns(:role).class.should eq(Role)
end
end

describe 'POST #create' do
	context "Role creation in valid" do
		it 'create a new Role' do
			params = {}
			params["role"] = {"name"=>"exec-text-role"}
			post :create, params
			#count is 3 becox factories create
			expect(Role.count).to eq(3)
		end
		it 'should not create new Role' do
			params = {}
			params["role"] = {"first_name"=>""}
			post :create, params
			expect(Role.count).to eq(2)
			expect(response.status).to eq(200)
		end
	end
end

end