class AddQuestionTypeId < ActiveRecord::Migration
  def up
    add_column :questions,:question_type_id,:integer
    add_column :answers,:free_text,:text
  end

  def down
    remove_column :questions,:question_type_id
    remove_column :answers,:free_text
  end
end
