class DistributePricingPlan < ActiveRecord::Migration
  def change
    create_table :distribute_pricing_plans do |t|
      t.string :plan_name, :null => false
      t.boolean :form_builder
      t.boolean :offline_mode
      t.boolean :nrts_results
      t.integer :surveys_count
      t.integer :responses_count
      t.boolean :tell_the_world
      t.boolean :multilingual
      t.boolean :professional_template
      t.boolean :multitenant_structure
      t.boolean :download_reports
      t.boolean :sentiment_analysis
      t.string  :media_content
      t.timestamps
    end
  end
end
