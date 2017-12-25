class AddIsHtmlInBackLog < ActiveRecord::Migration
  def change
    add_column :backlog_email_lists, :is_html, :boolean
  end
end
