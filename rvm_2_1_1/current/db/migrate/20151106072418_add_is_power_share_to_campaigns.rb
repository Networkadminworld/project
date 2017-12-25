class AddIsPowerShareToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_power_share, :boolean
  end
end
