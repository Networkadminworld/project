class ChangeDescriptionTypeInRegion < ActiveRecord::Migration
  def self.up
      change_column :tenant_regions, :description, :string
      change_column :tenant_types, :description, :string
  end

  def self.down
    change_column :tenant_regions, :description, :integer
    change_column :tenant_types, :description, :integer
  end
end
