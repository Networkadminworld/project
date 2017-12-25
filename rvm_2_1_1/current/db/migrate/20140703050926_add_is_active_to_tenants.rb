class AddIsActiveToTenants < ActiveRecord::Migration
  def self.up
    add_column :tenants, :is_active, :boolean, :default => true
  end
  def self.down
    add_column :tenants, :is_active, :boolean, :default => nil
  end
end
