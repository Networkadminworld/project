class CampaignMobileCustomer < ActiveRecord::Migration
  def change
    create_table :campaign_customers do |t|
      t.integer :campaign_channel_id
      t.integer :campaign_id
      t.integer :business_customer_info_id
      t.timestamps
    end
    add_index :campaign_customers, :campaign_id
    add_index :campaign_customers, :business_customer_info_id
    add_index :campaign_customers, :campaign_channel_id
  end
end
