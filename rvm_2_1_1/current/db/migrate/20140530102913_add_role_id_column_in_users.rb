class AddRoleIdColumnInUsers < ActiveRecord::Migration
  def up
    add_column :users ,:role_id, :integer
  end

  def down
    remove_column :users ,:role_id
  end
end
