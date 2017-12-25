class AddEmailHourlyQuotaInClientSetting < ActiveRecord::Migration
  def change
    add_column :client_settings, :email_hourly_quota, :integer, limit: 8
  end
end
