class PricingPlanChannel < ActiveRecord::Base
  belongs_to :plannable, polymorphic: true
end