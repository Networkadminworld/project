FactoryGirl.define do
  factory :permission do
    controller_name "test_cases"
    action_name "index"
    access_level false
  end
end	