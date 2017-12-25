class AddColumnCookieTokenIdInBusinessCustomerInfos < ActiveRecord::Migration
  def up
    add_column :business_customer_infos,:cookie_token_id,:integer
  end

  def down
    remove_column :business_customer_infos,:cookie_token_id,:integer
  end
end
