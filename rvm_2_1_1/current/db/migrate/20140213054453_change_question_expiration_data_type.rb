class ChangeQuestionExpirationDataType < ActiveRecord::Migration
  def up
   change_column :questions, :expired_at, :datetime
   change_column :users, :exp_date, :datetime
  end

  def down
   change_column :questions, :expired_at, :date
   change_column :users, :exp_date, :date
  end
end
