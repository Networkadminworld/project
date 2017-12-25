class RenameCampaignStyles < ActiveRecord::Migration
  def change
    rename_column :campaign_details, :campaign_styles, :campaign_short_urls
  end
end
