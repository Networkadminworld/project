class ChangeIsUnsubscribedDataType < ActiveRecord::Migration
  def change
	change_column :business_customer_infos, :is_unsubscribed, :string
  end
end
