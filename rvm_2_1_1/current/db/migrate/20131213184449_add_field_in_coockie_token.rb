class AddFieldInCoockieToken < ActiveRecord::Migration
  def up
	add_column :cookie_tokens,:has_location,:boolean
  end

  def down
	remove_column :cookie_tokens,:has_location,:boolean
  end
end
