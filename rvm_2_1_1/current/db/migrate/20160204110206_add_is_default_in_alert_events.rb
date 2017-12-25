class AddIsDefaultInAlertEvents < ActiveRecord::Migration
  def change
    add_column :alert_events, :is_default, :boolean
  end
  add_index :alert_configs, :alert_event_id
end
