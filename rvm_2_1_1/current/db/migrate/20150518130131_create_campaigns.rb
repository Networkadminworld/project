class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :label
      t.datetime :exp_date
      t.string :campaign_end_url
      t.string :hash_tag
      t.string  :media_url
      t.string  :media_thumb_url
      t.boolean :two_way_campaign
      t.boolean :is_active
      t.boolean :is_embed_media
      t.datetime :schedule_on
      t.integer :user_id
      t.integer :campaign_type_id
      t.integer :share_medium_id
    end
  end
end
