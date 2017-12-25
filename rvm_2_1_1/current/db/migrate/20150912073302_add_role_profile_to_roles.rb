class AddRoleProfileToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :profile, :text
  end
end
