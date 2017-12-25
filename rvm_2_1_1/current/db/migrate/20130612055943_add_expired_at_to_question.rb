class AddExpiredAtToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions,:expired_at,:date
  end
  def self.down
    remove_column :questions,:expired_at
  end
end
