require 'spec_helper'
require 'factory_girl_rails'

describe CorporateUsersController do
	  before(:each){
    User.delete_all
    Role.delete_all
    @role = FactoryGirl.create(:role,:first_plan)
    @pricing_plan = PricingPlan.where(plan_name: "Business").first
    @user = FactoryGirl.create(:user,:default_user,:role_id => @role.id,:authentication_token => "8982jd9sjdskd02ejskdsdoj",:business_type_id => @pricing_plan.business_type_id.to_i,:parent_id => 0 )
    @tenant = FactoryGirl.create(:tenant)
    @tenant_build = FactoryGirl.build :tenant
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)
    controller.stub(:check_role_level_permissions).and_return(true)
    controller.stub(:check_tenant).and_return(true)
    #controller.stub(:set_corporate_user).and_return(@user)
    controller.stub(:current_user) { @user }
  }
	
 describe "GET index" do
	it "renders the index template" do
		get :index
		expect(response.status).to eq(200)
	end
	#~ it "setting variables to params" do
	#~ end
end
	
 describe "GET #new" do 
  it "build new object for User with check tenant" do 
		expect(controller).to receive(:check_tenant).and_call_original
    get :new
			response.should redirect_to "/tenants"
		end
end

describe 'POST #create' do
	context "corporate user creation in valid" do
		it 'create a new User' do
			params = {}
			params["user"] = {"first_name"=>"mark", "last_name"=>"paul", "email"=>"test123@inquirly.com", "tenant_id"=>@tenant.id, "role_id"=>5, "parent_id"=> @user.id}
			post :create, params
			#count is 2 becase factory create one parent, here controller create one corporate user
			expect(User.count).to eq(2)
			expect(response.status).to eq(200)
		end
		it 'should not create new user' do
			params = {}
			params["user"] = {"first_name"=>"mark", "last_name"=>"paul", "email"=>"", "tenant_id"=>@tenant.id, "role_id"=>5, "parent_id"=> @user.id}
			post :create, params
			expect(User.count).to eq(1)
			expect(response.status).to eq(200)
		end
	end
end

describe 'Update #update' do
	before :each do
		@corporate_user = FactoryGirl.create(:user,:tenant_user,:role_id => @role.id,:authentication_token => "9082jd9sjdskd02ejsk33sdoj",:business_type_id => @pricing_plan.business_type_id.to_i,:parent_id => @user.id )
	end
	context "update the croporate user details" do
		it "should update the user" do
			put :update, id: @corporate_user, user: { first_name: "David", last_name: "raja",email: @corporate_user.email, role_id: @role.id, step: 2, tenant_id: @tenant.id}
    @corporate_user.reload 
    @corporate_user.first_name.should eq("David") 
    @corporate_user.last_name.should eq("raja") 
	 end
		it "should not update the user" do
			put :update, id: @corporate_user, user: { first_name: "", last_name: "raja",email: @corporate_user.email, role_id: @role.id, step: 2, tenant_id: @tenant.id}
    @corporate_user.reload 
    @corporate_user.first_name.should eq("test") 
		expect(response.status).to eq(200)
		end
	end
end

describe "#destroy" do
	before :each do
		@corporate_user = FactoryGirl.create(:user,:tenant_user,:role_id => @role.id,:authentication_token => "9082jd9sjdskd02ejsk33sdoj",:business_type_id => @pricing_plan.business_type_id.to_i,:parent_id => @user.id )
	end
	it "must respond with status 200" do
		delete :destroy, id: @corporate_user.id, authentication_token: @user.authentication_token
		response.should redirect_to "/corporate_users"
	end
end

describe 'Active the Corporate User and reset password' do
		before :each do
		@corporate_user = FactoryGirl.create(:user,:tenant_user,:role_id => @role.id,:authentication_token => "9082jd9sjdskd02ejsk33sdoj",:business_type_id => @pricing_plan.business_type_id.to_i,:parent_id => @user.id,:tenant_id => @tenant.id )
	end
  it "sholud active the user" do
    post :change_user_status, user_id: @corporate_user.id, is_active: "false"
    parsed_body = JSON.parse(response.body)
    parsed_body["is_active"].should == false
    expect(response.status).to eq(200)
  end
   it "sholud not active the user" do
    post :change_user_status, user_id: @corporate_user.id, is_active: "true"
    parsed_body = JSON.parse(response.body)
    parsed_body["is_active"].should == true
    expect(response.status).to eq(200)
  end
	  it "sholud reset the password" do
    post :reset_password, user_id: @corporate_user.id
    parsed_body = JSON.parse(response.body)
    parsed_body["message"].should == "New password emailed to user #{@corporate_user.first_name}"
    expect(response.status).to eq(200)
  end
	end

describe "#search_user" do
	before :each do
		@corporate_user = FactoryGirl.create(:user,:tenant_user,:role_id => @role.id,:authentication_token => "9082jd9sjdskd02ejsk33sdoj",:business_type_id => @pricing_plan.business_type_id.to_i,:parent_id => @user.id )
	end
	it "search user" do
		get :search_user, term: @corporate_user.email
		expect(JSON.parse(response.body)[0]["label"]).to eq("tenant@gmail.com")
	end
	it "search user not exists" do
		get :search_user, term: @user.email
		expect(JSON.parse(response.body)[0]).to eq(nil)
	end	
end

describe "#get_all_user" do
	it "get all user" do
		get :get_all_user
		expect(JSON.parse(response.body)[0]).to eq(@user.email)
	end
end

describe "#search_user_by_email" do
	it "search user by email" do
		user = FactoryGirl.create(:user, :default_biz_user, parent_id: @user.id)
		xhr :get, :search_user_by_email, email: user.email
		expect(response.status).to eq(200)
	end
end

describe "#update_tenant_users" do
	it "update_tenant_users for user_ids present" do
		tenant = FactoryGirl.create(:tenant, client_id: @user.id)
		user = FactoryGirl.create(:user, :default_biz_user, parent_id: @user.id, tenant_id: @tenant.id, role_id: @role.id)
		executive_tenant_mapping = FactoryGirl.create(:executive_tenant_mapping, user_id: @user.id, tenant_id: tenant.id)
		params = {user_id: user.id, user_ids: User.all.map(&:id), tenant_ids: [tenant.id]}
		xhr :put, :update_tenant_users, params
		expect(response.status).to eq(200)
	end
	it "update_tenant_users for user_ids present" do
		tenant = FactoryGirl.create(:tenant, client_id: @user.id)
		user = FactoryGirl.create(:user, :default_biz_user, parent_id: @user.id, tenant_id: @tenant.id, role_id: @role.id)
		executive_tenant_mapping = FactoryGirl.create(:executive_tenant_mapping, user_id: @user.id, tenant_id: tenant.id)
		params = {user_id: user.id, tenant_ids: [tenant.id]}
		xhr :put, :update_tenant_users, params
		expect(response.status).to eq(200)
	end	
end
end
