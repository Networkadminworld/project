class CreateAddColumnQuestionStatuses < ActiveRecord::Migration
  def up
    add_column :questions,:view_status, :string
  end
  def down
    remove_column :questions, :view_status
  end
end
