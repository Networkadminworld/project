FactoryGirl.define do
  factory :business_customer_info,class: BusinessCustomerInfo do
    mobile "1234567890"
    customer_name "Srinivasa Ramanujam"
    email "ramanujam@gmail.com"
    response_status true
    view_status true
    gender "male"
    provider "Facebook"
    date_of_birth (Date.today - 20.years)
    age 20
    country "IN"
    state "TN"
    city "Chennai"
    area "Alwarpet"
  end
end
