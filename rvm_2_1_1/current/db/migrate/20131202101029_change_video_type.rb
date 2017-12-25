class ChangeVideoType < ActiveRecord::Migration
  def up
    rename_column :questions, :video_type, :video_type_new
    add_column :questions, :video_type, :integer
    remove_column :questions, :video_type_new
  end

  def down
  end
end
