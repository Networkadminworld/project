FactoryGirl.define do
  factory :attachment do
    trait :user_info_csv do
      supporting_documentation_file_name { 'user_info.csv' }
      supporting_documentation_content_type { 'text/csv' }
    end

    trait :user_image do

    end
  end
end
