class CreatePowerShareStats < ActiveRecord::Migration
  def change
    create_table :power_share_stats do |t|
      t.string  :post_id
      t.string  :channel
      t.integer :campaign_id
      t.integer :campaign_channel_id
      t.integer :views
      t.integer :reaches
      t.timestamps
    end

    add_column :users, :security_token, :string
  end
end
