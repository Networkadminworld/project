class RemoveStatusFromShareQuestionAndAddStatusToUser < ActiveRecord::Migration
  def up
    remove_column :share_questions, :social_network_status
    add_column :users, :fb_status, :boolean ,:default => false
    add_column :users, :twitter_status, :boolean ,:default => false
    add_column :users, :linkedin_status, :boolean ,:default => false
  end

  def down
    add_column :share_questions, :social_network_status, :boolean , :default => false
    remove_column :users, :fb_status
    remove_column :users, :twitter_status
    remove_column :users, :linkedin_status
  end
end