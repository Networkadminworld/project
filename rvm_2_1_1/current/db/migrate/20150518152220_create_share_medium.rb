class CreateShareMedium < ActiveRecord::Migration
  def change
    create_table :share_mediums do |t|
      t.string :share_type
      t.boolean :is_active, default: true
    end
  end
end
