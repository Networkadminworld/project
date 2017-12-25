class CreateBillingInfoDetails < ActiveRecord::Migration
  def change
    create_table :billing_info_details do |t|
      t.integer :user_id
      t.string :billing_name
      t.string :billing_email
      t.string :billing_address
      t.string :billing_city
      t.string :billing_state
      t.string :billing_country
      t.integer :billing_zip ,:limit => 5
      t.string :billing_phone
      t.timestamps
    end
  end
end
