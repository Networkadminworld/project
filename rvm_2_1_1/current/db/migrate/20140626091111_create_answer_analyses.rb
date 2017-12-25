class CreateAnswerAnalyses < ActiveRecord::Migration
  def change
    create_table :answer_analyses do |t|
      t.integer :answer_id,:null =>false
      t.integer  "question_id", :null =>false
      t.integer :sentiment_score,:null =>false
      t.timestamps
    end
  end
end
