class AddCookieTokenId < ActiveRecord::Migration
  def up
	add_column :response_cookie_infos,:cookie_token_id,:integer
  end

  def down
  end
end
