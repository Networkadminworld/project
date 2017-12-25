class AddTenantDetailsInTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :phone, :string
    add_column :tenants, :contact_number, :string
    add_column :tenants, :email, :string
    add_column :tenants, :region,:string
    add_column :tenants, :tenant_type, :string

    add_column :tenants, :website_url, :string
    add_column :tenants, :facebook_url, :string
    add_column :tenants, :twitter_url, :string
    add_column :tenants, :linkedin_url, :string

    add_column :users, :mobile, :string
  end
end
