class AddIndexToBusinessCustomerInfos < ActiveRecord::Migration
  def change
  	add_index :business_customer_infos, :email
  	add_index :business_customer_infos, :country
  end
end
