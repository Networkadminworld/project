class CreateCampaignTypes < ActiveRecord::Migration
  def change
    create_table :campaign_types do |t|
      t.string :campaign_type
      t.string :name
    end
  end
end
