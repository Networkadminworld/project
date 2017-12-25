require "spec_helper"

describe PricingPlan do

describe "Create New pricing plan and format it" do
	it "should be equal to pricing plan hash map" do
       plan = PricingPlan.create(plan_name: "Test plan", business_type_id: 1,tenant_count: 0,customer_records_count: 1000,language_count: 1,question_suggestions: false,questions_count: 10)
       cat = PricingCategoryType.create(pricing_plan_id: plan.id,category_type_id: 1 )
       pricing_plans = PricingPlan.define_pricing_plans
       expect($pricing_plans).to eq(pricing_plans)
    end
end

describe "update pricing plan" do
	it "should update pricing hash map" do
       plan = PricingPlan.create(plan_name: "Test plan", business_type_id: 1,tenant_count: 0,customer_records_count: 1000,language_count: 1,question_suggestions: false,questions_count: 10)
       cat = PricingCategoryType.create(pricing_plan_id: plan.id,category_type_id: 1 )
       pricing_plans = plan.update_attributes(customer_records_count: 2000,language_count: 3)
       pricing_plans = PricingPlan.define_pricing_plans
       expect($pricing_plans).to eq(pricing_plans)
   end
end

describe "update pricing plan categories" do
	it "should update categories in pricing hash map" do
       plan = PricingPlan.create(plan_name: "Test plan", business_type_id: 1,tenant_count: 0,customer_records_count: 1000,language_count: 1,question_suggestions: false,questions_count: 10)
       cat = PricingCategoryType.create(pricing_plan_id: plan.id,category_type_id: 1 )
       pricing_plans = plan.update_attributes(category_type_ids:["1","2"])
       pricing_plans = PricingPlan.define_pricing_plans
       expect($pricing_plans).to eq(pricing_plans)
   end
 end

 it "should display all plans" do
	 expect(PricingPlan.list_all_plans.count).to eq(PricingPlan.count)
	end      
        
 it "should display settings plans" do
	 expect(PricingPlan.get_settings_plans).to eq(PricingPlan.where("expired_date is null and id > ?",1))
 end
 
 it "should display order by amount desc" do
	 expect(PricingPlan.order_by_amount.last).to eq(PricingPlan.get_all_plans.order("amount DESC").last)
 end

 it "should display order by amount asc" do
	 expect(PricingPlan.order_by_amount_asc.last).to eq(PricingPlan.get_all_plans.order("amount ASC").last)
 end
 
  describe "change_plan_check" do
		it "return current plan" do
			pplan = PricingPlan.first
		 expect(PricingPlan.change_plan_check(pplan.id, pplan.id)).to eq("current_plan")
	 end
		it "return current plan" do
			pplan1 = PricingPlan.first
			pplan2 = PricingPlan.second
		 expect(PricingPlan.change_plan_check(pplan1.id, pplan2.id)).to eq("upgrade")
	 end
	 		it "return current plan" do
			pplan1 = PricingPlan.first
			pplan2 = PricingPlan.second
		 expect(PricingPlan.change_plan_check(pplan2.id, pplan1.id)).to eq("downgrade")
		end
 end
 
  it "should find pricing plan" do
	 expect(PricingPlan.find_pricing_plan(PricingPlan.last.id).last).to eq(PricingPlan.last)
 end
end