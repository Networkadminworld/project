class RemoveDefaultToUserSocialStatus < ActiveRecord::Migration
  def up
    change_column :users, :fb_status, :string, :default => nil
    change_column :users, :twitter_status, :string, :default => nil
    change_column :users, :linkedin_status, :string, :default => nil
  end

  def down
    change_column :users, :fb_status, :string, :default => false
    change_column :users, :twitter_status, :string, :default => false
    change_column :users, :linkedin_status, :string, :default => false
  end
end
