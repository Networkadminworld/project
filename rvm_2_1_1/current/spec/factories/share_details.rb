FactoryGirl.define do
  factory :share_detail do
    customer_records_count 100
    questions_count 5
    video_photo_count 3
    sms_count 1
    call_count 3
    email_count 10
  end
end