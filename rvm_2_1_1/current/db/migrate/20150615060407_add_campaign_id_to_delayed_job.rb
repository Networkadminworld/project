class AddCampaignIdToDelayedJob < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :campaign_id, :integer
    add_column :delayed_jobs, :user_id, :integer
  end
end
