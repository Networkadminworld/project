class AddFunnelMarketingStateIdToFunnels < ActiveRecord::Migration
  def change
    add_column :funnels, :funnel_marketing_state_id, :integer
  end
end
