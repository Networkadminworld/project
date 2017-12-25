FactoryGirl.define do
  factory :user do
    confirmed_at Time.now - 1.hour
    confirmation_sent_at Time.now - 2.hour
    created_at Time.now
    updated_at Time.now
    # password "A123bcdef!"
    # password_confirmation "A123bcdef!"

    trait :admin_user do
      id '8'
      first_name "inquirly"
      last_name "Admin"
      company_name "Inquirly"
      email "admin#{Random.rand(114444444)}@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327#{Random.rand(114444444)}48384384834"
      business_type_id 1
      is_active true
      admin true
      subscribe true
      step "1"
      parent_id 0
    end

    trait :subscribed_biz_user do
      first_name "inquirly"
      last_name "Admin"
      company_name "Inquirly"
      email "admin#{Random.rand(114444444)}@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327#{Random.rand(114444444)}48384384834"
      business_type_id 2
      is_active true
      admin false
      subscribe true
      exp_date Time.now + 2.months
    end
    trait :sub_end_user do
      first_name "inquirly"
      last_name "Admin"
      company_name "Inquirly"
      email "admin#{Random.rand(114444444)}@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327#{Random.rand(114444444)}48384384834"
      business_type_id 2
      is_active true
      admin false
      subscribe true
      exp_date Time.now + 7.days
    end

    trait :subscribe_false_biz_user do
      first_name "inquirly"
      last_name "Admin"
      company_name "Inquirly"
      email "admin#{Random.rand(114444444)}@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327#{Random.rand(114444444)}48384384834"
      business_type_id 2
      is_active true
      subscribe false
      exp_date Time.now - 7.days
    end

    trait :subscribe_expired_biz_user do
      first_name "inquirly"
      last_name "Admin"
      company_name "Inquirly"
      email "admin#{Random.rand(114444444)}@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327#{Random.rand(114444444)}48384384834"
      business_type_id 2
      is_active true
      subscribe true
      exp_date Time.now - 2.months
    end

    trait :invalid_email_user_factory do
      first_name "inquirly"
      last_name "Admin"
      company_name "Inquirly"
      email "admin"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327#{Random.rand(114444444)}48384384834"
      business_type_id 4
      is_active true
      admin true
      subscribe false
      step "1"
    end

    trait :default_biz_user do
      first_name "Bijane"
      last_name "Stone"
      company_name "Inquirly"
      email "bija#{Random.rand(1166454444)}ne@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327374348384384834"
      business_type_id 2
      is_active true
      admin false
      exp_date Time.now - 2.months
    end

    trait :default_user do
      first_name "Cold"
      last_name "Stone"
      company_name "Inquirly"
      email "cold#{Random.rand(1166454444)}@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 1
      is_active true
      admin false
      exp_date Time.now + 1.month
    end

    trait :user_all do
      first_name "test"
      last_name "test"
      company_name "test Comapny Name"
      email "test@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active 'true'
      admin false
      exp_date Time.now + 1.month
    end

    trait :mis_match_confirmation do
      first_name "Test"
      last_name "Test"
      company_name "Test Comapny Name"
      email "test@gmail.com"
      password "A@123456a"
      business_type_id 2
      is_active true
      admin false
    end

    trait :without_first_name do
      last_name "test"
      company_name "test"
      email "test@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active true
      admin false
    end

    trait :without_last_name do
      first_name "test"
      company_name "test"
      email "test@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active true
      admin false
    end

    trait :without_company_name do
      first_name "test"
      last_name "test"
      email "test@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active true
      admin false
    end

    trait :without_email do
      first_name "test"
      last_name "test"
      company_name "test"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active true
      admin false
    end

    trait :without_password do
      first_name "test"
      last_name "test"
      company_name "test"
      email "test@gmail.com"
      business_type_id 2
      password nil
      password_confirmation :nil
      is_active true
      admin false
    end

    trait :without_password_confirmation do
      first_name "test"
      last_name "test"
      company_name "test"
      email "test@gmail.com"
      password "A@123456a"
      business_type_id 2
      is_active true
      admin false
    end
    trait :without_bussiness_type do
      first_name "test"
      last_name "test"
      company_name "test"
      email "test@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      is_active true
      admin false
    end

    trait :facebook_user do
      first_name "Test"
      last_name "Test"
      company_name "Test Comapny Name"
      email "facebook@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active true
      admin false
      provider "facebook"
      fb_status 'true'
      exp_date Time.now + 2.months
    end

    trait :twitter_user do
      first_name "Test"
      last_name "Test"
      company_name "Test Comapny Name"
      email "twitter@gmail.com"
      password "A@123456a"
      password_confirmation "A@123456a"
      business_type_id 2
      is_active true
      admin false
      provider "twitter"
      twitter_oauth_secret "5555555555555555555555"
      twitter_status 'true'
      exp_date Time.now + 2.months
    end

    trait :linkedin_user do
      first_name "Test"
      last_name "Test"
      company_name "Test Comapny Name"
      email "linkedin@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active true
      admin false
      provider "linkedin"
      linkedin_secret_token "5555555555555555555555"
      linkedin_status 'true'
      exp_date Time.now + 2.months
    end

    trait :google_user do
      first_name "Test"
      last_name "Test"
      company_name "Test Comapny Name"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active true
      admin false
      provider "google"
      exp_date Time.now + 2.months
    end
    trait :user_with_listener do
      first_name "Bijane"
      last_name "Stone"
      company_name "Inquirly"
      email "bijane@inquirly.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      authentication_token "45327374348384384834"
      business_type_id 2
      is_active true
      admin false
      exp_date Time.now - 2.months
      association(:listener, factory: :existing_listener)
    end

    trait :tenant_user do
      first_name "test"
      last_name "test"
      company_name "test Comapny Name"
      email "tenant@gmail.com"
      password "Inquirly123!"
      password_confirmation "Inquirly123!"
      business_type_id 2
      is_active 'true'
      admin false
      exp_date Time.now + 1.month
    end
  end
end