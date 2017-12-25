require "spec_helper"

describe ExecutiveTenantMapping do
  before(:each) {
    @user = FactoryGirl.create(:user,:default_biz_user)
    @tenant = FactoryGirl.create(:tenant)
    @executive_tenant = FactoryGirl.create(:executive_tenant_mapping, user_id: @user.id, tenant_id: @tenant.id)
  }

	describe "#get_tenant_ids" do
		 it "should get tenant ids" do
			tenant_ids = ExecutiveTenantMapping.get_tenant_ids(@user.id)
			expect(tenant_ids).to eq([@tenant.id])
		end
	end

	describe "#already_mapped_user" do
		 it "check is already mapped user" do
			tenant_ids = ExecutiveTenantMapping.already_mapped_user(@user.id)
			expect(tenant_ids.last).to eq(@tenant.id)
		end
		 it "check is already mapped user when user id is nil" do
			tenant_ids = ExecutiveTenantMapping.already_mapped_user(nil)
			expect(tenant_ids.last).to eq(nil)
		end		
	end	
end