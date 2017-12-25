class RemoveAnswerOption < ActiveRecord::Migration
  def up
    remove_column :questions, :answer_options
  end

  def down
    add_column :questions, :answer_options, :string
  end
end
