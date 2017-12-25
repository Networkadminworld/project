class CreateCronLogs < ActiveRecord::Migration
  def change
    create_table :cron_logs do |t|
    t.integer :last_run_id
    t.string  :log_type
    t.timestamps
    end
  end
end
