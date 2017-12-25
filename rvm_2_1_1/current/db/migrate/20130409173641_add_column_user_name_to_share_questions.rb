class AddColumnUserNameToShareQuestions < ActiveRecord::Migration
  def self.up
    add_column :share_questions, :user_name, :string
    add_column :share_questions, :user_profile_image, :string
  end

  def self.down
    remove_column :share_questions, :user_name
    remove_column :share_questions, :user_profile_image
  end
end
