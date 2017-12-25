class AddPiwikIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :piwik_id, :integer
  end
end
