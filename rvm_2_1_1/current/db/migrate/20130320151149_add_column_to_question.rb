class AddColumnToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :status, :string ,:default => "Inactive"
  end

  def self.down
    remove_column :questions, :status
  end
end
