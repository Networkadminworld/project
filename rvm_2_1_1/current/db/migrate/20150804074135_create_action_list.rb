class CreateActionList < ActiveRecord::Migration
  def change
    create_table :action_lists do |t|
      t.string :action
      t.float  :weight
      t.string :url
      t.timestamps
    end
  end
end
