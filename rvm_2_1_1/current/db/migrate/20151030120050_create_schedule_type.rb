class CreateScheduleType < ActiveRecord::Migration
  def change
    create_table :schedule_types do |t|
      t.string  :name
      t.boolean :is_active
      t.text :schedule_days, default: {'MONDAY' => true, 'TUESDAY' => true, 'WEDNESDAY' => true, 'THURSDAY' => true, 'FRIDAY' => true, 'SATURDAY' => true, 'SUNDAY' => true}
      t.integer :user_id
      t.timestamps
    end
  end
end
