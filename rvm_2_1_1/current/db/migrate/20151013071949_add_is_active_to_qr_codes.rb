class AddIsActiveToQrCodes < ActiveRecord::Migration
  def change
    add_column :qr_codes, :is_active, :boolean
    add_column :qr_code_campaigns, :is_active, :boolean
  end
end
