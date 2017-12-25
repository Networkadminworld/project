class AddCustomColumnsToPricingPlan < ActiveRecord::Migration
  def up
    add_column :pricing_plans ,:listener_slots, :integer
    add_column :pricing_plans ,:custom_feeds,:integer
    add_column :pricing_plans ,:email_alerts, :boolean
  end
  def down
    remove_column :pricing_plans ,:listener_slots
    remove_column :pricing_plans ,:custom_feeds
    remove_column :pricing_plans ,:email_alerts
  end
end
