class AddResponseToTransaction < ActiveRecord::Migration
  def up
    add_column :transaction_details, :zaakpay_response, :text
    add_column :transaction_details, :response_dec, :string
    add_column :transaction_details, :response_code, :integer
  end

  def down
    remove_column  :transaction_details, :zaakpay_response
    remove_column  :transaction_details, :response_dec
    remove_column  :transaction_details, :response_code
  end
end
