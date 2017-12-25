class CreateExecutiveBusinessMapping < ActiveRecord::Migration
  def change
    create_table :executive_business_mappings do |t|
      t.integer :user_id
      t.integer :company_id
      t.timestamps
    end
    add_index :executive_business_mappings, :user_id
    add_index :executive_business_mappings, :company_id
  end
end
