class AddQuestionIdInBacklog < ActiveRecord::Migration
  def change
    add_column :backlog_email_lists, :question_id, :integer
  end
end
