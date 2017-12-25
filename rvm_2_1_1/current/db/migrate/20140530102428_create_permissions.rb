class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :role_id,null: false
      t.string :controller_name,null: false
      t.string :action_name,null: false
      t.integer :access_level,null: false
      t.timestamps
    end
  end
end
