class RemoveColumnsFromResponseCookieInfo < ActiveRecord::Migration
  def up
	remove_column :response_cookie_infos,:uuid
  end

  def down
  end
end
