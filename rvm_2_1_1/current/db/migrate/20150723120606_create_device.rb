class CreateDevice < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :device_id
      t.integer :user_id
      t.timestamps
    end
  end
end
