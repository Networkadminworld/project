class ChangeEmailArrayTypeInBacklog < ActiveRecord::Migration
  def up
    change_column :backlog_email_lists, :email_array, :text
  end

  def down
    change_column :backlog_email_lists, :email_array, :string
  end
end
