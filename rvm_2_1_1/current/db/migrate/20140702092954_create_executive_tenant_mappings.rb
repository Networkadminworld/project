class CreateExecutiveTenantMappings < ActiveRecord::Migration
  def change
    create_table :executive_tenant_mappings do |t|
      t.integer :user_id
      t.integer :tenant_id
      t.integer :client_id
      t.boolean :is_active
      t.timestamps
    end
  end
end
