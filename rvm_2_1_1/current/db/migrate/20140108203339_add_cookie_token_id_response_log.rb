class AddCookieTokenIdResponseLog < ActiveRecord::Migration
  def up
	  add_column :question_response_logs,:cookie_token_id,:integer
  end

  def down
  end
end
