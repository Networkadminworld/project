class AddStatusForTransaction < ActiveRecord::Migration
  def up
    add_column :transaction_details, :active, :boolean, :default => false
    add_column :transaction_details, :action, :string
  end

  def down
    remove_column :transaction_details, :active
    remove_column :transaction_details, :action
  end
end