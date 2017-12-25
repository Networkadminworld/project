require "spec_helper"

describe Role do
 
	it { should have_many(:permissions) }
	it { should have_one(:user) }
	it "should have a name"  do
		Role.create(name: nil).should_not be_valid
	end
	it "should hava unique name"  do
		role_name = Role.last.name
		Role.create(name: role_name).should_not be_valid
	end	

	it "get role of the user" do
    pricing_plan = PricingPlan.where(plan_name: "Business").first
		role = Role.first
    user = FactoryGirl.create(:user,:default_user,:role_id => role.id,:business_type_id => pricing_plan.business_type_id.to_i,:parent_id => 0 )		
		expect(Role.get_role(user)).to eql(4)
	end
	
	it "get all roles" do
		expect(Role.get_all_roles.count).to eq(3)
	end	

	it "default roles with custom roles" do
    pricing_plan = PricingPlan.where(plan_name: "Business").first
		role = Role.first
    user = FactoryGirl.create(:user,:default_user,:role_id => role.id,:business_type_id => pricing_plan.business_type_id.to_i,:parent_id => 0 )		
		expect(Role.roles_and_custom_roles(user).count).to eql(2)
	end	
	
	it "get tenant roles" do
    pricing_plan = PricingPlan.where(plan_name: "Business").first
		role = Role.first
    user = FactoryGirl.create(:user,:default_user,:role_id => role.id,:business_type_id => pricing_plan.business_type_id.to_i,:parent_id => 0 )		
		expect(Role.get_tenant_roles(user).count).to eql(2)
	end		
	
	it "get role by id" do
		role = Role.last
		expect(Role.get_role_by_id(role.id)).to eq(role)
	end		
end