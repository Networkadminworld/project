class AddDistributePricingPlanToUser < ActiveRecord::Migration
  def change
	add_column :users, :distribute_pricing_plan_id, :integer
  end
end
