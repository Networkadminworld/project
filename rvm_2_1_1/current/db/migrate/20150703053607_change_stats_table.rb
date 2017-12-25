class ChangeStatsTable < ActiveRecord::Migration
  def change
    add_column :campaign_channels, :post_id, :string
    add_column :campaign_channels, :connections, :integer
    add_column :campaign_channels, :reach, :integer
    add_column :power_share_stats, :connections, :integer
    add_column :power_share_stats, :reach, :integer
    add_column :power_share_stats, :share_medium_id, :integer
    remove_column :power_share_stats, :campaign_channel_id
    remove_column :power_share_stats, :reaches
    rename_table :power_share_stats, :campaign_activity_stats
  end
end
