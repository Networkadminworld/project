class CreateInqCampaign < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'inq_campaigns'
      create_table :inq_campaigns do |t|
        t.string :uuid
        t.integer :user_id
        t.string :name
        t.string :state
        t.string :hash_tag
        t.string :campaign_type
        t.text :redirect_url
        t.text :campaign_url
        t.text :preview_data
        t.text :override_preview
        t.text :cards
        t.text :bitly_url
        t.datetime :valid_till
        t.datetime :scheduled_on
        t.datetime :added_on
        t.integer :inq_campaign_id
        t.timestamps
      end
    end
  end
end
