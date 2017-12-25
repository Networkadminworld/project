class AddBitlyFieldsInQuestion < ActiveRecord::Migration
  def up
  	add_column :questions ,:twitter_short_url,:string
  	add_column :questions ,:linkedin_short_url,:string
  	add_column :questions ,:qrcode_short_url,:string
  	add_column :questions ,:sms_short_url,:string
  end

  def down
  	remove_column :questions ,:twitter_short_url,:string
  	remove_column :questions ,:linkedin_short_url,:string
  	remove_column :questions ,:qrcode_short_url,:string
  	remove_column :questions ,:sms_short_url,:string
  end
end
