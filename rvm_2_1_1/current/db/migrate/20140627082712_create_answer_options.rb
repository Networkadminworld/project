class CreateAnswerOptions < ActiveRecord::Migration
  def change
    create_table :answer_options do |t|
      t.integer :question_id,null: false
      t.hstore   :options,null: false
      t.timestamps
    end
  end
end
