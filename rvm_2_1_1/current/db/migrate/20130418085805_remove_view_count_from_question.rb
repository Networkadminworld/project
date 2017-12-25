class RemoveViewCountFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :view_count
  end

  def down
    add_column :questions, :view_count , :integer ,:default => 0
  end
end