class AddIsPageToSocialChannels < ActiveRecord::Migration
  def change
    add_column :user_social_channels, :is_page, :boolean
    add_column :user_social_channels, :admin_id, :integer
  end
end
