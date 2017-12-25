class AddSocialNetworkStatus < ActiveRecord::Migration
  def up
    add_column :share_questions, :social_network_status, :boolean ,:default => false
  end

  def down
    remove_column :share_questions, :social_network_status
  end
end