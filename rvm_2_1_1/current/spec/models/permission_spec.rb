require "spec_helper"

describe Permission do
  it { should belong_to(:role) }
  
  describe "get_user_permissions" do
    it "should get user permissions as empty" do
      user = FactoryGirl.create(:user, :default_biz_user)
      permissions = Permission.get_user_permissions(user)
      expect(permissions).to be_empty
    end
    it "should get user permissions" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
      permissions = Permission.get_user_permissions(user)
      expect(permissions).not_to be_empty
    end		
  end
	
  describe "define_permissions" do
    it "should define permissions as empty" do
      user = FactoryGirl.create(:user, :default_biz_user)
      permissions = Permission.define_permissions(user)
      expect(permissions).to be_empty
    end
    it "should get user permissions" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
      permissions = Permission.define_permissions(user)
      expect(permissions).not_to be_empty
    end		
  end

  describe "check_controller_permission" do
    it "should check controller permission as true" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permissions = Permission.define_permissions(user)
      check_permission = Permission.check_controller_permission("admin/listeners" ,user, permissions)
      expect(check_permission).to eq(true)
    end	
    it "should check controller permission as false" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permissions = Permission.define_permissions(user)
      check_permission = Permission.check_controller_permission("admin/listeners2" ,user, permissions)
      expect(check_permission).to eq(false)
    end			
  end
	
  describe "check_action_permission" do
    it "should check action permission as true" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permissions = Permission.define_permissions(user)
      check_permission = Permission.check_action_permission("index", "admin/listeners", permissions)
      expect(check_permission).to eq(true)
    end	
    it "should check action permission as nil" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permissions = Permission.define_permissions(user)
      check_permission = Permission.check_action_permission("nothing", "admin/listeners", permissions)
      expect(check_permission).to eq(nil)
    end			
  end	
	
  describe "check_user_role_permissions" do
    it "should check user role permission as true" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permissions = Permission.define_permissions(user)
      check_permission = Permission.check_user_role_permissions("admin/listeners", "index", user, permissions)
      expect(check_permission).to eq(true)
    end	
    it "should check user role permission as false" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permissions = Permission.define_permissions(user)
      check_permission = Permission.check_user_role_permissions("admin/listeners2", "index", user, permissions)
      expect(check_permission).to eq(false)
    end			
  end	
	
  describe "check_feature_permission" do
    it "should check feature permission as true" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permission = Permission.get_user_permissions(user).last
      check_permission = Permission.check_feature_permission(permission, 2)
      expect(check_permission).to eq(true)
    end	
    it "should check feature permission as false" do
      user = FactoryGirl.create(:user, :default_biz_user, role_id: 2)
			permission = Permission.get_user_permissions(user).last
      check_permission = Permission.check_feature_permission(permission, nil)
      expect(check_permission).to eq(false)
    end			
  end		
	
  describe "update_or_create" do
    it "update the permission" do
			FactoryGirl.create(:permission, :role_id => 2)
			args = {controller_name: "test_cases", action_name: "index", role_id: 2}
      check_permission = Permission.update_or_create(args,1)
      expect(check_permission).to eq(true)
    end	
    it "create the permission" do
			args = {controller_name: "test_cases", action_name: "index", role_id: 2}
      check_permission = Permission.update_or_create(args,1)
      expect(check_permission.access_level).to eq(true)
    end			
  end	
end