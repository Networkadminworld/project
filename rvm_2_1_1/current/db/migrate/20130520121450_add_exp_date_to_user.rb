class AddExpDateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :exp_date, :date
    add_column :users, :is_active, :boolean
  end

  def self.down
    remove_column :users, :exp_date
    remove_column :users, :is_active
  end
end