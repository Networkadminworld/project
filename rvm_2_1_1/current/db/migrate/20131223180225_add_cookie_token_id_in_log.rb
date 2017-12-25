class AddCookieTokenIdInLog < ActiveRecord::Migration
  def up
    add_column :question_view_logs, :cookie_token_id, :integer
    add_index :question_view_logs, :cookie_token_id
  end

  def down
  end
end
