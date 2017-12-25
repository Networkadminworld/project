class AddSlugToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :slug, :string
    add_column :qr_code_campaigns, :campaign_slug, :string
    add_column :qr_codes, :slug, :string
    add_index :campaigns, :slug
    add_index :qr_code_campaigns, :campaign_slug
    add_index :qr_codes, :slug
  end
end
