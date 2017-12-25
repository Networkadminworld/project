class CreateAddQrcodeToQuestions < ActiveRecord::Migration
 def self.up
    add_column :questions, :qrcode_status, :string
  end
  def self.down
    remove_column :questions, :qrcode_status
  end
end
