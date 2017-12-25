class CreateCampaignDetails < ActiveRecord::Migration
  def change
    create_table :campaign_details do |t|
      t.text    :campaign_data
      t.text    :campaign_styles
      t.integer :campaign_id
      t.integer :share_medium_id
      t.integer :template_id
      t.timestamps
    end

    create_table :user_channels do |t|
      t.text    :channel_type
      t.integer :channel_id
      t.integer :share_medium_id
      t.integer :user_id
      t.timestamps
    end

    create_table :campaign_channels do |t|
      t.integer :campaign_id
      t.integer :share_medium_id
      t.integer :user_channel_id
      t.timestamps
    end

    create_table :user_social_channels do |t|
      t.string  :channel
      t.text    :social_id
      t.text    :social_token
      t.string  :email
      t.string  :name
      t.string  :profile_image
      t.integer  :user_id
      t.boolean :active
      t.timestamps
    end

    create_table :user_mobile_channels do |t|
      t.string  :channel
      t.integer  :contact_group_id
      t.integer  :user_id
      t.boolean :active
      t.timestamps
    end

    create_table :contact_groups do |t|
      t.string  :name
      t.integer :user_id
      t.timestamps
    end

    add_column :campaigns, :status, :string
    add_column :business_customer_infos, :contact_group_id, :integer

    add_index :campaign_details, :campaign_id
    add_index :campaign_details, :share_medium_id
    add_index :campaign_details, :template_id
    add_index :user_channels, :channel_id
    add_index :user_channels, :share_medium_id
    add_index :campaign_channels, :share_medium_id
    add_index :campaign_channels, :campaign_id
    add_index :campaign_channels, :user_channel_id
    add_index :user_mobile_channels, :contact_group_id
    add_index :contact_groups, :user_id
  end
end
