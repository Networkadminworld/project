class CreateListeners < ActiveRecord::Migration
  def change
    create_table :listeners do |t|
      t.string :client_id
      t.integer :user_id
      t.string :email
      t.string :username
      t.string :password
      t.string :status
      t.boolean :is_active, :default=>false
      t.boolean :is_requested, :default=>false

      t.timestamps
    end
      add_index :listeners, [:user_id]
  end
end
