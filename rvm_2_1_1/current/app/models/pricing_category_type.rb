class PricingCategoryType < ActiveRecord::Base
	belongs_to :pricing_plan
	belongs_to :category_type
	after_save :reload_pricing_plan

	private

  def reload_pricing_plan
     ActiveSupport::Dependencies.load_file "config/initializers/pricing_plan.rb"
  end

end
