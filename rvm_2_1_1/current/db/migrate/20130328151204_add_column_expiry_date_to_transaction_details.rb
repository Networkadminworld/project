class AddColumnExpiryDateToTransactionDetails < ActiveRecord::Migration
  def self.up
    add_column :transaction_details, :expiry_date, :datetime
    add_column :transaction_details, :order_id, :string
  end

  def self.down
    remove_column :transaction_details, :expiry_date
    remove_column :transaction_details, :order_id
  end
end
