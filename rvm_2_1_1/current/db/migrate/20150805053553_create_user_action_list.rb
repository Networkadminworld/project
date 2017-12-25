class CreateUserActionList < ActiveRecord::Migration
  def change
    create_table :user_action_lists do |t|
      t.boolean :completed
      t.integer :user_id
      t.integer :action_list_id
      t.timestamps
    end
  end
end
