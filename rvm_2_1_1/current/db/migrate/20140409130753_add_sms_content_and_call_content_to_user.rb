class AddSmsContentAndCallContentToUser < ActiveRecord::Migration
   def self.up
    add_column :users, :sms_content, :string
    add_column :users, :call_content, :string
  end
  def self.down
    remove_column :users, :sms_content
    remove_column :users, :call_content
  end
end
