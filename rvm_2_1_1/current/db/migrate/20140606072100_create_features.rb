class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.integer :parent_id,null: false
      t.string :controller_name,null: false
      t.string :action_name
      t.string :title,null: false
      t.timestamps
    end
  end
end
