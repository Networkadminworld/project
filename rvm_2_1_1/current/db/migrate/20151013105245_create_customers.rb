class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :salutation
      t.string :landline
      t.string :mobile
      t.integer :address_id

      t.timestamps
    end
  end
end
