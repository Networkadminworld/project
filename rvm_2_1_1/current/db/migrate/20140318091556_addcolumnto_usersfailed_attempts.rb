class AddcolumntoUsersfailedAttempts < ActiveRecord::Migration
  def up
    add_column :users , :failed_attempts, :integer
    add_column :users , :unlock_token, :string
    add_column :users , :locked_at, :datetime
  end

  def down
    remove_column :users, :failed_attempts
    remove_column :users, :unlock_token
    remove_column :users, :locked_at
  end
end
