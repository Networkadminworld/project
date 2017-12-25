require 'spec_helper'

describe Admin::PermissionsController do
	
  before(:each){
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = FactoryGirl.create(:user,:admin_user, :business_type_id => 4)
    sign_in :user, @user
	}
	
	it "#index get all roles" do
		get :index
		expect(assigns[:roles].count).to eq(3)
	end
	
	describe "#edit should render the edit form with details" do
		it "#edit should render the edit form with details with correct role" do
			get :edit, id: Role.last.id
			#~ expect(assigns[:role]).to eq(Role.last)
			expect(assigns[:parent_features].count).to eq(Feature.where(:parent_id => 0).count)
		end
		it "#edit should render the edit form with details with wrong role" do
			get :edit, id: Role.last.id
			#~ expect(assigns[:role].name).to eq(Role.last.name)
			expect(assigns[:parent_features].count).to eq(Feature.where(:parent_id => 0).count)
		end		
	end
	
	describe "#update should update the edit form with details" do
		it "#edit should render the edit form with details with correct role" do
			role_id = Role.last.id
			feature_hash = {}
			Feature.all.each {|feature| feature_hash["#{feature.controller_name}-" + "#{feature.action_name}-#{role_id}"] = 1}
			params = {feature: feature_hash, id: role_id}
			get :update, params
			response.should redirect_to "/admin/permissions"
		end
	end	
end