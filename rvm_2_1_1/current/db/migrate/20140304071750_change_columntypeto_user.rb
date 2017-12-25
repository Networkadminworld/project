class ChangeColumntypetoUser < ActiveRecord::Migration
  def up
    change_column :users, :email_content, :text
  end

  def down
    change_column :users, :email_content, :string
  end
end
