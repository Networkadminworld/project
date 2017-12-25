class AddAttachmentImageToQrCodes < ActiveRecord::Migration
  def self.up
    change_table :qr_codes do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :qr_codes, :image
  end
end
