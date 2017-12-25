class AddUserIdInQuestionViewLogs < ActiveRecord::Migration
  def up
    add_column :question_view_logs,:user_id, :integer
    add_column :question_response_logs,:user_id, :integer
  end

  def down
    remove_column :question_view_logs,:user_id
    remove_column :question_response_logs,:user_id
  end
end
