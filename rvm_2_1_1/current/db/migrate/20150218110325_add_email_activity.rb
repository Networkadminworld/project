class AddEmailActivity < ActiveRecord::Migration
  def change
    create_table :email_activities do |t|
      t.integer :opens
      t.integer :clicks
      t.string :subject
      t.string :campaign_name
      t.integer :question_id
      t.integer :user_id
      t.integer :business_customer_info_id
      t.timestamps
    end
  end
end
