class DropAnswerTypeIdFromQuestions < ActiveRecord::Migration
  def up
	remove_column :questions, :answer_type_id
  end

  def down
  end
end
