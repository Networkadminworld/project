class CreateResponseCustomerInfos < ActiveRecord::Migration
  def change
    create_table :response_customer_infos do |t|
      t.string :mobile
      t.string :customer_name
      t.string :email
      t.boolean :response_status
      t.boolean :view_status
      t.string :gender
      t.string :question_id
      t.string :provider
      t.date :date_of_birth
      t.integer :age
      t.string :country
      t.string :state
      t.string :city
      t.string :area
      t.string
      t.timestamps
    end
  end
end