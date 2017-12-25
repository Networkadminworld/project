class RenameFunnelSourceId < ActiveRecord::Migration
  def change
    rename_column :funnels, :source_id, :funnel_source_id
  end
end
