class ChangeUuidTypeInAnswers < ActiveRecord::Migration
  def up
	change_column :answers, :uuid, :integer
  end

  def down
  end
end
