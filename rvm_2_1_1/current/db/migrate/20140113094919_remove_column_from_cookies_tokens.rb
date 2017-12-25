class RemoveColumnFromCookiesTokens < ActiveRecord::Migration
  def up
    remove_column :cookie_tokens, :has_location
  end

  def down
     add_column :cookie_tokens, :has_location, :boolean
  end
end
