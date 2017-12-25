class AddFeatureIdInPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :feature_id, :integer
    remove_column :permissions, :controller_name
    remove_column :permissions, :action_name
  end
end
