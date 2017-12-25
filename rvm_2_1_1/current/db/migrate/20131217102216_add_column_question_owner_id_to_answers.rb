class AddColumnQuestionOwnerIdToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :question_owner_id, :integer
    add_index :answers, :question_owner_id
  end
end
