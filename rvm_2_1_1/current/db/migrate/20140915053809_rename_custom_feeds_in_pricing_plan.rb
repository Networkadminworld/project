class RenameCustomFeedsInPricingPlan < ActiveRecord::Migration
  def up
    rename_column :pricing_plans, :custom_feeds, :crawler_slots
  end

  def down
    rename_column :pricing_plans, :crawler_slots, :custom_feeds
  end
end
