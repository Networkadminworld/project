require "spec_helper"

describe Tenant do
 
 it "has a valid factory" do 
	 FactoryGirl.create(:tenant).should be_valid 
 end 
 it "should have a name"  do
  FactoryGirl.build(:tenant, name: nil).should_not be_valid
 end
 
 describe "Active and deactive the tenant" do
  before :each do 
     @tenant = FactoryGirl.create(:tenant)
     @tenant_inactive = FactoryGirl.create(:tenant_inactive)
  end
   it "should active the tenant" do
    active = Tenant.change_tenant_status({tenant_id: @tenant.id, is_active: "false"})
    expect(active).to eq(false)
   end
   it "should deactive the tenant" do
    active = Tenant.change_tenant_status({tenant_id: @tenant_inactive.id, is_active: "true"})
    expect(active).to eq(true)
   end
  end
  
 describe "#get_tenant" do
   it "get tenant parent id not zero" do
    suser = FactoryGirl.create(:user,:default_biz_user)
    tenant = FactoryGirl.create(:tenant, client_id: suser.id)    
    user = FactoryGirl.create(:user,:facebook_user, :uid => "1234", parent_id: suser.id, tenant_id: tenant.id)
    FactoryGirl.create(:executive_tenant_mapping, user_id: user.id, tenant_id: tenant.id, is_active: true)
    result = Tenant.get_tenant(user)
   end
   it "get tenant parent id not zero" do
    user = FactoryGirl.create(:user,:default_biz_user)
    tenant = FactoryGirl.create(:tenant, client_id: user.id)    
    result = Tenant.get_tenant(user)
    expect(result.first).to eq(tenant)
   end
 end

end