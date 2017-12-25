class CreateQrCodeCampaign < ActiveRecord::Migration
  def change
    create_table :qr_code_campaigns do |t|
      t.integer :qr_code_id
      t.integer :campaign_id
      t.string  :campaign_short_url
      t.string  :campaign_long_url
      t.boolean :is_scheduled
      t.timestamps
    end
  end
end
