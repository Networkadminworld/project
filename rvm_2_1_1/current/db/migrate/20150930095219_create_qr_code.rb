class CreateQrCode < ActiveRecord::Migration
  def change
    create_table :qr_codes do |t|
      t.string  :name
      t.string  :short_url
      t.boolean :status
      t.boolean :is_default
      t.integer :user_id
      t.timestamps
    end
  end
end
