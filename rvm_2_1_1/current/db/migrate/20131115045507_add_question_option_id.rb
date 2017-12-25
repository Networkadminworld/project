class AddQuestionOptionId < ActiveRecord::Migration
  def up
    add_column :answers,:question_option_id,:integer
  end
  def down
    remove_column :answers,:question_option_id,:integer
  end
end
