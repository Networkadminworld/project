class CreateUserConfig < ActiveRecord::Migration
  def change
    create_table :user_configs do |t|
      t.text :engage
      t.text :listen
      t.text :others
      t.integer :user_id
      t.timestamps
    end
  end
end
