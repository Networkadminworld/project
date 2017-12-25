class CreateShareSummaries < ActiveRecord::Migration
  def change
    create_table :share_summaries do |t|
      t.integer :customer_records_count, :null => false,default: 0
      t.integer :questions_count,:null => false,default: 0
      t.integer :video_photo_count,:null => false,default: 0
      t.integer :sms_count,:null => false,default: 0
      t.integer :call_count,:null => false,default: 0
      t.integer :email_count,:null => false,default: 0
      t.integer :user_id,:null => false,default: 0
      t.datetime :last_shared_date ,:null => false
      t.timestamps
    end
  end
end
