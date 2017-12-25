class AddLatLngColumnsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :lat, :float
    add_column :companies, :lng, :float
    remove_column :companies, :logo_url
  end
end
