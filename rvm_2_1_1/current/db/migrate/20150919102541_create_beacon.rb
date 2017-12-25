class CreateBeacon < ActiveRecord::Migration
  def change
    create_table :beacons do |t|
      t.string  :name
      t.string  :uid
      t.boolean :status
      t.integer :user_id
      t.timestamps
    end
  end
end
