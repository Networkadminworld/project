class AddIsArchivedToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_archived, :boolean, default: false
  end
end
