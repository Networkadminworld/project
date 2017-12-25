class CreateResponseCookieInfos < ActiveRecord::Migration
  def change
    create_table :response_cookie_infos do |t|
      t.string :uuid
      t.references :response_token, :polymorphic => true
      t.timestamps
    end
  end
end
