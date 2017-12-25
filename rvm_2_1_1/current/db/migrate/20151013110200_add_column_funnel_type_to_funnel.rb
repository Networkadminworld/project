class AddColumnFunnelTypeToFunnel < ActiveRecord::Migration
  def change
    add_column :funnels, :funnel_type_id, :integer
  end
end
