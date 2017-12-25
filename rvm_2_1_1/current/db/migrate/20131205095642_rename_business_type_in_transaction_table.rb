class RenameBusinessTypeInTransactionTable < ActiveRecord::Migration
  def up
    rename_column :transaction_details, :bussiness_type_id, :business_type_id
  end

  def down
    rename_column :transaction_details, :business_type_id, :bussiness_type_id
  end
end
