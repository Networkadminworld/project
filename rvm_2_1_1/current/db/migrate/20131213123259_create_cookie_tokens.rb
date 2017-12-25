class CreateCookieTokens < ActiveRecord::Migration
  def change
    create_table :cookie_tokens do |t|
      t.string :uuid
      t.timestamps
    end
  end
end
