class CreateBusinessCustomerInfos < ActiveRecord::Migration
  def change
    create_table :business_customer_infos do |t|
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
      t.integer :user_id
      t.string :country
      t.string :state
      t.string :city
      t.string :area
      t.string
      t.timestamps
    end
  end
end
