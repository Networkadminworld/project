class CreateBillingInfos < ActiveRecord::Migration
  def change
    create_table :billing_infos do |t|
      t.integer :user_id
      #t.integer :id
      t.string :name_on_card
      t.date :month
      t.date :year
      t.integer :cvv

      t.timestamps
    end
  end
end
