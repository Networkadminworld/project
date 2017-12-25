FactoryGirl.define do
  factory :client_setting do
  	trait :client_feature_settings do
        business_type_id 1
        tenant_count 0
        customer_records_count 1000
        language_count 1
        email_count 0
        sms_count 0
        video_photo_count 0
        call_count 0
    end
end
end