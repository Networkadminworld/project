class CreateFunnelTypes < ActiveRecord::Migration
  def change
    create_table :funnel_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
