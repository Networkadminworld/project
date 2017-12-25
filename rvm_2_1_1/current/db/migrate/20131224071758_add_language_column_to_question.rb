class AddLanguageColumnToQuestion < ActiveRecord::Migration
  def change
    add_column :questions,:language,:string ,:default => "English"
  end
end
