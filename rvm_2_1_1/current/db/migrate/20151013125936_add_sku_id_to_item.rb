class AddSkuIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :sku_id, :string
  end
end
