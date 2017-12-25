class ShareSummary < ActiveRecord::Base
 belongs_to :user
 belongs_to :share_detail

 def self.create_monthly_record(user_id,share_detail)
   create(user_id: user_id,customer_records_count: share_detail.customer_records_count,questions_count: share_detail.questions_count,video_photo_count: share_detail.video_photo_count,sms_count: share_detail.sms_count,call_count: share_detail.call_count,email_count: share_detail.email_count,last_shared_date: share_detail.updated_at)
 end

end
