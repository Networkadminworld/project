class FontStyle < ActiveRecord::Migration
  def change
    create_table :font_styles do |t|
      t.string   :name
      t.timestamps
    end
  end
end
