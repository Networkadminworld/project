FactoryGirl.define do
  factory :pricing_plan do
  	trait :test_pricing_plan do
        plan_name "Test plan"
        business_type_id 1
        tenant_count 10
        customer_records_count 1000
        language_count 1
        question_suggestions TRUE
        questions_count 0
        video_photo_count 0
        qr_share true
        sms_count 10
        call_count 12
        email_count 8
        social_share true
        embed_share true
        listener true
        redirect_url true
        from_number true
        listener_slots 1
        crawler_slots 1
        email_alerts false
        amount 100
  end
   trait :test_pricing_plan_1 do
        plan_name "Test plan 1"
        business_type_id 2
        tenant_count 10
        customer_records_count 1000
        language_count 1
        question_suggestions TRUE
        questions_count 0
        video_photo_count 0
  end
      trait :test_pricing_plan_2 do
        plan_name "Test plan 2"
        business_type_id 2
        tenant_count 10
        customer_records_count 1000
        language_count 1
        question_suggestions TRUE
        questions_count 0
        video_photo_count 0
      end
end
end