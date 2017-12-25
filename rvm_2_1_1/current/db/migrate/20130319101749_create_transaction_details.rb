class CreateTransactionDetails < ActiveRecord::Migration
  def change
    create_table :transaction_details do |t|
      t.integer :user_id
      t.integer :bussiness_type_id
      t.float :amount
      t.string :transaction_id
      t.string :profile_id

      t.timestamps
    end
  end
end
