class AddVideoUrl < ActiveRecord::Migration
  def change
    add_column :questions, :video_url, :string
    drop_attached_file :questions, :video
  end
end
