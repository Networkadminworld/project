class AddDeliveryBoyIdToFunnels < ActiveRecord::Migration
  def change
    add_column :funnels, :delivery_boy_id, :integer
  end
end
