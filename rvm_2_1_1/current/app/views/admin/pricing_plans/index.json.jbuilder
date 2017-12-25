json.array!(@pricing_plans) do |pricing_plan|
  json.extract! pricing_plan, :id, :plan_name, :business_type_id, :tenant_count, :customer_records_count, :category_type_ids, :language_count
  json.url pricing_plan_url(pricing_plan, format: :json)
end
