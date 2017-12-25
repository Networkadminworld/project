class CreateTableQuestionOptions < ActiveRecord::Migration
  def up
    create_table :question_options do |t|
      t.integer :question_id
      t.string :option
      t.timestamps
    end
  end

  def down
    drop_table :question_options
  end
end


