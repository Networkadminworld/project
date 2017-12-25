class AddUuidInAnswers < ActiveRecord::Migration
  def up
    add_column :answers,:uuid,:integer
  end

  def down
    remove_column :answers,:uuid,:integer
  end
end
