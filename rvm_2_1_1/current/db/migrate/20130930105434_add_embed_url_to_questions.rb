class AddEmbedUrlToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :embed_url, :string
    add_column :questions, :video_type, :string
  end
end
