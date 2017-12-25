class AddColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_oauth_token, :string
    add_column :users, :twitter_oauth_secret, :string
  end

  def self.down
    remove_column :users, :twitter_oauth_token
    remove_column :users, :twitter_oauth_secret
  end

end
