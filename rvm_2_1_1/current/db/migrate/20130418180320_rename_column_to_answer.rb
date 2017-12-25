class RenameColumnToAnswer < ActiveRecord::Migration
  def self.up
    rename_column :answers, :user_id, :customers_info_id
  end

  def self.down
    rename_column :answers, :customers_info_id, :user_id
  end
end