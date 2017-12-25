class AddSubscribeToUser < ActiveRecord::Migration
  def change
    add_column :users, :subscribe, :boolean ,:default => false
  end

  def down
    remove_column :users, :subscribe
  end
end
