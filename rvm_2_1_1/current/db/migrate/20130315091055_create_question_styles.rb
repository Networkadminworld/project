class CreateQuestionStyles < ActiveRecord::Migration
  def change
    create_table :question_styles do |t|
      t.integer :question_id
      t.string :background
      t.string :page_header
      t.string :submit_button
      t.string :question_text
      t.string :button_text
      t.string :answers
      t.string :font_style
      t.timestamps
    end
  end
end
