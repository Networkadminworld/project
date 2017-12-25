class CreateInvite < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :name
      t.string :email
      t.string :invite_code
      t.datetime :invite_expired_at
      t.timestamps
    end
  end
end
