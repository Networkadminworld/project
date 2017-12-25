class AddCookieTokenIdInResponseCustomerInfo < ActiveRecord::Migration
  def up
    add_column :response_customer_infos, :cookie_token_id, :integer
  end

  def down
  end
end
