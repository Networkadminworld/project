class AddViewCount < ActiveRecord::Migration
  def up
    add_column :questions, :view_count, :integer , :default => 0
  end

  def down
    remove_column :questions, :view_count
  end
end
