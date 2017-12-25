class CreateAlertSchemas < ActiveRecord::Migration
  def change

    create_table :alerts do |t|
      t.string :name
      t.timestamps
    end

    create_table :alert_types do |t|
      t.string :name
      t.timestamps
    end

    create_table :alert_channels do |t|
      t.string :name
      t.timestamps
    end

    create_table :alert_events do |t|
      t.string :name
      t.boolean :is_set_on
      t.integer :user_id
      t.integer :company_id
      t.integer :alert_id
      t.integer :alert_type_id
      t.timestamps
    end

    add_index :alert_events, :alert_id
    add_index :alert_events, :alert_type_id
    add_index :alert_events, :user_id

    create_table :alert_event_channels do |t|
      t.boolean :is_active
      t.integer :alert_event_id
      t.integer :alert_channel_id
      t.timestamps
    end

    add_index :alert_event_channels, :alert_event_id
    add_index :alert_event_channels, :alert_channel_id

    create_table :alert_logs do |t|
      t.text    :event_params
      t.string  :event_post_id
      t.boolean :is_viewed, defaut: :false
      t.integer :user_id
      t.integer :alert_event_id
      t.integer :alert_channel_id
      t.timestamps
    end

    add_index :alert_logs, :user_id
    add_index :alert_logs, :alert_event_id
    add_index :alert_logs, :alert_channel_id

  end
end
