class AddConnectionsToSocial < ActiveRecord::Migration
  def change
    add_column :user_social_channels, :connections, :integer
    add_column :user_social_channels, :valid_oauth, :boolean
  end
end
