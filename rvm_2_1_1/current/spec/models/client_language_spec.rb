require "spec_helper"

describe ClientLanguage do
 
	it { should belong_to(:client_setting) }
	it { should belong_to(:language) }

	describe "create client languages" do
		it "save the client languages" do
			user = FactoryGirl.create(:user,:default_biz_user, :role_id => Role.first.id)
			FactoryGirl.create(:client_setting, :client_feature_settings, user_id: user.id, pricing_plan_id: PricingPlan.last.id)
			result = ClientLanguage.create_new_record(user, Language.last(2).map(&:id))
			expect(result).to eq(true)
			expect(ClientLanguage.count).to eq(2)
		end
		it "discard the client languages" do
			user = FactoryGirl.create(:user,:default_biz_user, :role_id => Role.first.id)
			result = ClientLanguage.create_new_record(user, [])
			expect(ClientLanguage.count).to eq(0)
		end		
	end
	
end