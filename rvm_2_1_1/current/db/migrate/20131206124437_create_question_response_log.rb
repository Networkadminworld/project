class CreateQuestionResponseLog < ActiveRecord::Migration
  def up
    create_table :question_response_logs do |t|
      t.integer :question_id
      t.string :provider
      t.timestamps
    end
  end

  def down
  end
end
