class AddTypeToBacklogEmailList < ActiveRecord::Migration
  def change
    add_column :backlog_email_lists, :email_type, :string
    add_column :backlog_email_lists, :attach_path, :string
    add_column :backlog_email_lists, :attach_type, :string
    add_column :backlog_email_lists, :attach_name, :string
  end
end
