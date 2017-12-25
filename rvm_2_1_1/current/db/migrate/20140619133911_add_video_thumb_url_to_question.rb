class AddVideoThumbUrlToQuestion < ActiveRecord::Migration
  def change
    add_column :questions ,:video_url_thumb,:string
  end
end
