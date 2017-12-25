class CreatePricingCategoryTypes < ActiveRecord::Migration
  def change
    create_table :pricing_category_types do |t|
      t.integer :category_type_id
      t.integer :pricing_plan_id
      t.timestamps
    end
  end
end
