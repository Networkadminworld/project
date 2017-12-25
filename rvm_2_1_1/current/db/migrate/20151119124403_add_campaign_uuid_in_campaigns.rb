class AddCampaignUuidInCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :campaign_uuid, :text
  end
end
