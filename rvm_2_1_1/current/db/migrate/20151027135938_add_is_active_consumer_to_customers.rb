class AddIsActiveConsumerToCustomers < ActiveRecord::Migration
  def change
    add_column :business_customer_infos, :is_active_consumer, :boolean
  end
end
