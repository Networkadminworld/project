class AddRedirectUrlToUser < ActiveRecord::Migration
  def up
    add_column :users, :redirect_url,:string
    add_column :tenants, :redirect_url,:string
    add_column :users, :from_number,:string
    add_column :tenants, :from_number,:string
    add_column :pricing_plans, :redirect_url,:boolean,:default => false
    add_column :pricing_plans, :from_number,:boolean ,:default => false
  end

  def down
    remove_column :users, :redirect_url
    remove_column :tenants, :redirect_url
    remove_column :users, :from_number
    remove_column :tenants, :from_number
    remove_column :pricing_plans, :redirect_url
    remove_column :pricing_plans, :from_number
  end
end
