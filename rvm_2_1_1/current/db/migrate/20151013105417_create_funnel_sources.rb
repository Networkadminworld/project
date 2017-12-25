class CreateFunnelSources < ActiveRecord::Migration
  def change
    create_table :funnel_sources do |t|
      t.string :name
      t.integer :campaign_id
      t.integer :web_id

      t.timestamps
    end
  end
end
