class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
       t.integer :user_id
      t.integer :category_type_id
      t.string :expiration_id
      t.string  :question
      t.string :answer_options
      t.boolean :include_other
      t.boolean :include_text
      t.string :answer_type_id
      t.boolean :include_comment
      t.timestamps
    end
  end
end
