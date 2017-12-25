class AddTenantInfoInTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :tenant_info, :text
  end
end
