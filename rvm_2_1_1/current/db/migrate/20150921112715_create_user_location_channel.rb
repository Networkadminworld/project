class CreateUserLocationChannel < ActiveRecord::Migration
  def change
    create_table :user_location_channels do |t|
      t.references :channel, polymorphic: true, index: true
      t.integer :user_id
      t.timestamps
    end
  end
end
