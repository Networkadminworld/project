class AddcolumnToTransactionDetail < ActiveRecord::Migration
  def up
    add_column :transaction_details ,:tracking_id, :string
    add_column :transaction_details ,:bank_ref_no,:string
    add_column :transaction_details ,:failure_message,:string
    add_column :transaction_details ,:payment_mode,:string
    add_column :transaction_details ,:card_name,:string
    add_column :transaction_details ,:status_code,:integer
    add_column :transaction_details ,:status_message,:string
    add_column :transaction_details ,:currency,:string
    add_column :transaction_details ,:request_plan_id,:integer
  end

  def down
    remove_column :transaction_details ,:tracking_id
    remove_column :transaction_details ,:bank_ref_no
    remove_column :transaction_details ,:failure_message
    remove_column :transaction_details ,:payment_mode
    remove_column :transaction_details ,:card_name
    remove_column :transaction_details ,:status_code
    remove_column :transaction_details ,:status_message
    remove_column :transaction_details ,:currency
    remove_column :transaction_details ,:request_plan_id
  end
end
