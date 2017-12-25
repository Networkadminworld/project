class CreatePricingPlans < ActiveRecord::Migration
  def change
    create_table :pricing_plans do |t|
      t.string :plan_name, :null => false
      t.integer :business_type_id, :null => false,unique: true
      t.integer :tenant_count, :null => false
      t.integer :customer_records_count, :null => false
      t.integer :language_count, :null => false
      t.string  :country,null: false,default: "IN"
      t.datetime :expired_date, :null => true
      t.boolean :question_suggestions,:null => false
      t.integer :questions_count,:null => false, :limit => 8
      t.timestamps
    end
  end
end
