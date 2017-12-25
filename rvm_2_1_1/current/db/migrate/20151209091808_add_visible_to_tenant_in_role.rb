class AddVisibleToTenantInRole < ActiveRecord::Migration
  def change
    add_column :roles, :visible_to_tenant, :boolean
  end
end
