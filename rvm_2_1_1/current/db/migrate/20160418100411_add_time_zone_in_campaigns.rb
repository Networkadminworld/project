class AddTimeZoneInCampaigns < ActiveRecord::Migration
  def change
     add_column :campaigns, :time_zone, :string
     add_column :users, :currency_code, :string
  end
end
