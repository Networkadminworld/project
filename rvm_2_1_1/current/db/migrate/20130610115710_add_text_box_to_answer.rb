class AddTextBoxToAnswer < ActiveRecord::Migration
  def self.up
    add_column :answers, :comments, :string
  end
  def self.down
    remove_column :answers, :comments
  end
end
