class AddStatusToTransactionTable < ActiveRecord::Migration
  def up
    add_column :transaction_details, :payment_status, :string
  end

  def down
    remove_column  :transaction_details, :payment_status
  end
end
