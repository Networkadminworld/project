class CreateFunnels < ActiveRecord::Migration
  def change
    create_table :funnels do |t|
      t.integer :item_id
      t.integer :quantity
      t.boolean :is_valid
      t.integer :state_id
      t.integer :delivery_type_id
      t.integer :customer_id
      t.integer :company_id
      t.json :spec_details
      t.integer :tracking_id
      t.integer :payment_mode_id
      t.integer :source_id

      t.timestamps
    end
  end
end
