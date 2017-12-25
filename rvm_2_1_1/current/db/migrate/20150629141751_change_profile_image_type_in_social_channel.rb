class ChangeProfileImageTypeInSocialChannel < ActiveRecord::Migration
  def change
    change_column :user_social_channels, :name, :text
    change_column :user_social_channels, :profile_image, :text
  end
end
