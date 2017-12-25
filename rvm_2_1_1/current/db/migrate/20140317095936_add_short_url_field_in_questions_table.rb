class AddShortUrlFieldInQuestionsTable < ActiveRecord::Migration
  def up
  	add_column :questions ,:short_url,:string
  end

  def down
 	remove_column :questions ,:short_url,:string
  end
end
