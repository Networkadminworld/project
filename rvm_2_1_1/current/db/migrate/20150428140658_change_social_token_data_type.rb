class ChangeSocialTokenDataType < ActiveRecord::Migration
  def change
    change_column :share_questions, :social_token, :text
    change_column :share_questions, :social_id, :text
    change_column :share_questions, :user_profile_image, :text
  end
end
