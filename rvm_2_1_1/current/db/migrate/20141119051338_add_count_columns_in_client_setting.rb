class AddCountColumnsInClientSetting < ActiveRecord::Migration
  def change
    add_column :client_settings ,:questions_count, :integer
    add_column :client_settings ,:video_photo_count, :integer
    add_column :client_settings ,:sms_count, :integer
    add_column :client_settings ,:call_count, :integer
    add_column :client_settings ,:email_count, :integer
  end
end
