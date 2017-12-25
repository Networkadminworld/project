class RemoveAnswerColumns < ActiveRecord::Migration
  def up
     remove_column :answers, :answer
     add_column :answers,:question_type_id,:integer
  end

  def down
     add_column :answers, :answer,:string
     remove_column :answers,:question_type_id
  end
end
