class CreateShareQuestions < ActiveRecord::Migration
  def change
    create_table :share_questions do |t|
      t.string :email_address
      t.string :provider
      t.string :social_id
      t.string :social_token
      t.integer :user_id
      t.timestamps
    end
  end
end
