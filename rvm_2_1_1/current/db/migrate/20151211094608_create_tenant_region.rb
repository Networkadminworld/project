class CreateTenantRegion < ActiveRecord::Migration
  def change
    create_table :tenant_regions do |t|
      t.string  :name
      t.integer :description
      t.integer :user_id
      t.boolean :is_active
      t.timestamps
    end

    create_table :tenant_types do |t|
      t.string  :name
      t.integer :description
      t.boolean :is_active
      t.integer :user_id
      t.timestamps
    end

    add_column :tenants, :tenant_region_id, :integer
    add_column :tenants, :tenant_type_id, :integer
    remove_column :tenants, :tenant_type
    remove_column :tenants, :region
  end
end
