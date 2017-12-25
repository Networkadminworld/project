FactoryGirl.define do
  factory :transaction_detail do
    amount 1000
    transaction_id "Qwertyu23344"
    profile_id "testuser123"
    expiry_date Time.now + 1.month
    order_id "ORDER123"
    active true
    action "nothing"
    payment_status "paid"
    zaakpay_response "this is test zaakpay account"
    response_dec "Test Response"
    response_code 23456
    business_type_id 2
  end
end
