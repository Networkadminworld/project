class AddLeadTitleToFunnels < ActiveRecord::Migration
  def change
    add_column :funnels, :lead_title, :string
  end
end
