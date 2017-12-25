class CreateIndustryTag < ActiveRecord::Migration
  def change
    create_table :industry_tags do |t|
      t.string :industry
      t.string :tag
      t.datetime :added_on
      t.timestamps
    end
  end
end
