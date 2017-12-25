class Channel < ActiveRecord::Base
  has_and_belongs_to_many :pricing_plans,
                          :association_foreign_key => 'pricing_plan_id',
                          :class_name => 'PricingPlan',
                          :join_table => 'pricing_plans_channels'
end