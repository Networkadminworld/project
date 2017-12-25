class CreateAlertConfig < ActiveRecord::Migration
  def change
    create_table :alert_configs do |t|
      t.text :email
      t.text :sms
      t.text :business_app
      t.text :consumer_app
      t.integer :alert_event_id
      t.timestamps
    end
  end
end
