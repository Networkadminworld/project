class AddUrlToQrCodes < ActiveRecord::Migration
  def change
    add_column :qr_codes, :url, :string
    add_index :qr_codes, :url
  end
end
