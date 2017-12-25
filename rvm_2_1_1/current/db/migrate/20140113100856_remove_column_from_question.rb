class RemoveColumnFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :view_status	
  end

  def down
    add_column :questions, :view_status, :string
  end
end
