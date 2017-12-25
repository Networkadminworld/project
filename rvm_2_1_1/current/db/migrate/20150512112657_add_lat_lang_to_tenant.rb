class AddLatLangToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :lat, :float
    add_column :tenants, :lng, :float
  end
end
