class AddConsumerIdInCustomers < ActiveRecord::Migration
  def change
    add_column :business_customer_infos, :consumer_id, :integer
    add_index :business_customer_infos, :consumer_id
  end
end
