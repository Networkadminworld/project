class ChangeBacklogSubjectAndMessgeType < ActiveRecord::Migration
  def up
    change_column :backlog_email_lists, :subject, :text
    change_column :backlog_email_lists, :message, :text
  end

  def down
    change_column :backlog_email_lists, :subject, :string
    change_column :backlog_email_lists, :message, :string
  end
end
