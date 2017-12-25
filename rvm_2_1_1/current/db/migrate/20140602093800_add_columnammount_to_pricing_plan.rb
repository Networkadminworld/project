class AddColumnammountToPricingPlan < ActiveRecord::Migration
  def change
    add_column :pricing_plans ,:amount,:float
  end
end
