class CreateScheduleSlot < ActiveRecord::Migration
  def change
    create_table :schedule_slots do |t|
      t.string  :slot
      t.integer :schedule_type_id
      t.timestamps
    end
  end
end
