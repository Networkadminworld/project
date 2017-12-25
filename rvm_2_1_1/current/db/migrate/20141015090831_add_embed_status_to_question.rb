class AddEmbedStatusToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :embed_status, :boolean, default: false
  end
end
