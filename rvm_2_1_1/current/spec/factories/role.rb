FactoryGirl.define do
  factory :role do
    trait :first_plan do
      name "Individual"
      is_default true
    end
  trait :test_role do
      name "test_role"
      is_default true
    end
    trait :invalid_role do
      name ""
      is_default true
    end
  end
end