class CreatePaymentModes < ActiveRecord::Migration
  def change
    create_table :payment_modes do |t|
      t.string :provider

      t.timestamps
    end
  end
end
