class AddIsUnsubscribedToBizCustomer < ActiveRecord::Migration
  def change
    add_column :business_customer_infos, :is_unsubscribed, :boolean, default: false
  end
end
