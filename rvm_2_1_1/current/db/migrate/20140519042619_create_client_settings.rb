class CreateClientSettings < ActiveRecord::Migration
  def change
    create_table :client_settings do |t|
      t.integer :user_id, null: false
      t.integer :pricing_plan_id, null: false
      t.integer :tenant_count
      t.integer :customer_records_count
      t.integer :language_count
      t.integer :business_type_id,unique: true
      t.timestamps
    end
  end
end
