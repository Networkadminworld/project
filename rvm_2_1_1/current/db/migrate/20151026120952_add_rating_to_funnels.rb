class AddRatingToFunnels < ActiveRecord::Migration
  def change
    add_column :funnels, :rating, :integer
  end
end
