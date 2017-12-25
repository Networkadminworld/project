class AddRedirectUrlInCompany < ActiveRecord::Migration
  def change
    add_column :companies, :redirect_url, :string
    remove_column :companies, :tags
  end
end
