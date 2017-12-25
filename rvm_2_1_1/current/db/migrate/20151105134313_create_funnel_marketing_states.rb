class CreateFunnelMarketingStates < ActiveRecord::Migration
  def change
    create_table :funnel_marketing_states do |t|
      t.string :action_name
      t.text :note
      t.date :appointment_at
      t.string :result
      t.integer :funnel_id

      t.timestamps
    end
  end
end
