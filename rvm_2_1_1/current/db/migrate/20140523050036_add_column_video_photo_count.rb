class AddColumnVideoPhotoCount < ActiveRecord::Migration
  def up
    add_column :pricing_plans ,:video_photo_count, :integer
    add_column :pricing_plans ,:qr_share,:boolean
    add_column :pricing_plans ,:sms_count,:integer
    add_column :pricing_plans ,:call_count,:integer
    add_column :pricing_plans ,:email_count,:integer
    add_column :pricing_plans ,:social_share,:boolean
    add_column :pricing_plans ,:embed_share,:boolean
    add_column :pricing_plans ,:listener,:boolean
  end

  def down
    remove_column :pricing_plans ,:video_photo_count
    remove_column :pricing_plans ,:qr_share
    remove_column :pricing_plans ,:sms_count
    remove_column :pricing_plans ,:call_count
    remove_column :pricing_plans ,:email_count
    remove_column :pricing_plans ,:social_share
    remove_column :pricing_plans ,:embed_share
    remove_column :pricing_plans ,:listener
  end
end
