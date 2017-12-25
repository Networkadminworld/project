class AddCampaignIdToFunnel < ActiveRecord::Migration
  def change
    add_column :funnels, :campaign_id, :string
  end
end
