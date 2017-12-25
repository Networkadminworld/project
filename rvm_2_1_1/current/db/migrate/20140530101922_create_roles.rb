class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name,null: false
      t.boolean :is_default,null: false,default: false
      t.integer :user_id
      t.timestamps
    end
  end
end
