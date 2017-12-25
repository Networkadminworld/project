class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.float :price
      t.boolean :is_active
      t.integer :specs_id
      t.integer :company_id
      t.string :image_url

      t.timestamps
    end
  end
end
