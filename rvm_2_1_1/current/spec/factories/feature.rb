FactoryGirl.define do
  factory :feature do
    controller_name "account"
    action_name "account"
    title "My Account"
		parent_id 0
  end
end