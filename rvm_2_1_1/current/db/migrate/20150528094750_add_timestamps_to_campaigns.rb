class AddTimestampsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :created_at, :datetime
    add_column :campaigns, :updated_at, :datetime
    add_column :campaign_types, :created_at, :datetime
    add_column :campaign_types, :updated_at, :datetime
    add_column :share_mediums, :created_at, :datetime
    add_column :share_mediums, :updated_at, :datetime
  end
end
