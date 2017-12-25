class RemoveColumnFromAnswers < ActiveRecord::Migration
  def up
    remove_column :answers, :multiple_response_id	
    remove_column :answers, :question_owner_id	
  end

  def down
    add_column :answers, :multiple_response_id, :integer
    add_column :answers, :question_owner_id, :integer
  end
end
