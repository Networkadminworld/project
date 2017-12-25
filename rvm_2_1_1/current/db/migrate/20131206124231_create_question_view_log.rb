class CreateQuestionViewLog < ActiveRecord::Migration
  def up
    create_table :question_view_logs do |t|
      t.integer :question_id
      t.string :provider
      t.timestamps
    end
  end

  def down
  end
end
