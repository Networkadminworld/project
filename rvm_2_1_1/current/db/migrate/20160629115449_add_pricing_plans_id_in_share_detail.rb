class AddPricingPlansIdInShareDetail < ActiveRecord::Migration
  def change
    add_column :client_pricing_plans, :total_reach, :integer
    add_column :share_details, :client_pricing_plan_id, :integer, index: true
    add_column :share_details, :total_reach, :integer
    add_column :pricing_plans_channels, :id, :integer
    add_column :pricing_plans_channels, :plannable_type, :string
    rename_column :pricing_plans_channels, :pricing_plan_id, :plannable_id
    rename_table :pricing_plans_channels, :pricing_plan_channels
  end
end
