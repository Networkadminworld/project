class AddCsvCustomColumn < ActiveRecord::Migration
  def up
    add_column :business_customer_infos ,:is_deleted, :boolean
    add_column :business_customer_infos ,:custom_field,:string
    add_column :response_customer_infos ,:user_id, :integer
    add_column :response_customer_infos ,:is_deleted, :boolean
  end
  def down
    remove_column :business_customer_infos ,:is_deleted
    remove_column :business_customer_infos ,:custom_field
    remove_column :response_customer_infos ,:user_id
    remove_column :response_customer_infos ,:is_deleted
  end
end
