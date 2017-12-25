class AddColumnToShareQuestions < ActiveRecord::Migration
  def self.up
    add_column :share_questions, :active, :boolean, :default => false
  end

  def self.down
    remove_column :share_questions, :active
  end
end
